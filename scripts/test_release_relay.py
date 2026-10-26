import json
import os
import re
import subprocess
import tempfile
import textwrap
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = (ROOT / '.github/workflows/release-relay.yml').read_text()
INPUT = '${{ github.event.inputs.source_tag || github.event.client_payload.tag }}'
OUTPUT = '${{ steps.tag.outputs.tag }}'


def step(name):
    body = WORKFLOW.split(f'      - name: {name}\n', 1)[1]
    return body.split('      - ', 1)[0]


def script(name):
    return textwrap.dedent(step(name).split('        run: |\n', 1)[1])


def run_script(source, directory, env):
    return subprocess.run(
        ['bash', '--noprofile', '--norc', '-e', '-o', 'pipefail', '-c', source],
        cwd=directory, env=env, capture_output=True, text=True, timeout=5,
    )


class ReleaseRelayTests(unittest.TestCase):
    def resolve(self, tag):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        root = Path(directory.name)
        output = root / 'output'
        environment_file = root / 'env'
        marker = root / 'executed'
        output.touch()
        environment_file.touch()
        env = {
            'PATH': os.defpath,
            'SOURCE_TAG': tag,
            'GITHUB_OUTPUT': str(output),
            'GITHUB_ENV': str(environment_file),
            'PAYLOAD_MARKER': str(marker),
        }
        source = script('Resolve source tag').replace(INPUT, tag)
        result = run_script(source, root, env)
        self.assertFalse(marker.exists())
        self.assertEqual(environment_file.read_text(), '')
        return result, output.read_text()

    def test_accepts_release_prerelease_and_build_tags(self):
        tags = ('v0.3.5', 'v0.1.0-alpha', 'v1.2.3-rc.1', 'v1.2.3+build.7', 'v1.2.3-rc.1+build.7')
        for tag in tags:
            with self.subTest(tag=tag):
                result, output = self.resolve(tag)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(output, f'tag={tag}\n')

    def test_rejects_invalid_tags_without_execution_or_output(self):
        tags = (
            '', 'latest', '1.2.3', '--help', 'v1.2', 'v1.2.3/',
            'v1.2.3 ', ' v1.2.3', 'v1.2.3\t', 'v1.2.3\r',
            'v1.2.3\n', 'v1.2.3\ntag=v9.9.9', 'v1.2.3\r\ntag=v9.9.9',
            'v1.2.3-', 'v1.2.3+', 'v1.2.3-rc..1',
            'v1.2.3$(touch "$PAYLOAD_MARKER")',
            'v1.2.3`touch "$PAYLOAD_MARKER"`',
            'v1.2.3"; touch "$PAYLOAD_MARKER"; #',
            'v1.2.3$(printf "BASH_ENV=/tmp/untrusted\\n" >> "$GITHUB_ENV")',
            'v1.2.3$(printf "tag=v9.9.9\\n" >> "$GITHUB_OUTPUT")',
        )
        for tag in tags:
            with self.subTest(tag=tag):
                result, output = self.resolve(tag)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(output, '')

    def test_untrusted_expressions_are_only_passed_as_data(self):
        runs = re.findall(r'(?m)^        run: \|\n((?:^          .*\n|^\n)+)', WORKFLOW)
        self.assertEqual(len(runs), 4)
        for source in runs:
            self.assertNotIn('${{', source)
        self.assertIn(f'          SOURCE_TAG: {INPUT}\n', step('Resolve source tag'))
        self.assertNotIn('secrets.', step('Resolve source tag'))
        self.assertTrue(WORKFLOW.split('    steps:\n', 1)[1].startswith('      - name: Resolve source tag\n'))
        for name in (
            'Download source release artifacts',
            'Pull release notes from source repo CHANGELOG',
            'Generate updater manifest (latest.json)',
        ):
            self.assertIn(f'          TAG: {OUTPUT}\n', step(name))
        self.assertIn(f'          tag_name: {OUTPUT}\n', step('Create mirrored release'))

    def test_manifest_keeps_the_validated_tag_in_download_urls(self):
        tag = 'v1.2.3-rc.1+build.7'
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            artifacts = root / 'artifacts'
            artifacts.mkdir()
            files = {
                'darwin-aarch64': 'Vect.app.tar.gz',
                'linux-x86_64': 'Vect.AppImage',
                'windows-x86_64': 'Vect-setup.exe',
            }
            for name in files.values():
                (artifacts / name).touch()
                (artifacts / f'{name}.sig').write_text('test-signature')
            result = run_script(script('Generate updater manifest (latest.json)'), root, {
                'PATH': os.defpath, 'TAG': tag, 'GITHUB_REPOSITORY': 'seonglae/vect',
            })
            self.assertEqual(result.returncode, 0, result.stderr)
            manifest = json.loads((artifacts / 'latest.json').read_text())
            self.assertEqual(manifest['version'], tag[1:])
            self.assertEqual(set(manifest['platforms']), set(files))
            for platform, name in files.items():
                self.assertEqual(manifest['platforms'][platform], {
                    'signature': 'test-signature',
                    'url': f'https://github.com/seonglae/vect/releases/download/{tag}/{name}',
                })


if __name__ == '__main__':
    unittest.main()
