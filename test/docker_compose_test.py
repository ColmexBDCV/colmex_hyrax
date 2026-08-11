import json
import re
import unittest
from pathlib import Path


PROJECT_ROOT = Path(__file__).parents[1]
COMPOSE_FILE = PROJECT_ROOT / "docker-compose.yml"
PACKAGE_FILE = PROJECT_ROOT / "package.json"


class DockerComposeDevelopmentTest(unittest.TestCase):
    def test_development_stack_binds_source_and_publishes_required_ports(self):
        compose = COMPOSE_FILE.read_text()

        self.assertIn(".:/app", compose)
        self.assertRegex(compose, r'"0\.0\.0\.0:3000:3000"')
        self.assertRegex(compose, r'"0\.0\.0\.0:6379:6379"')
        self.assertRegex(compose, r'"0\.0\.0\.0:8983:8983"')
        self.assertRegex(compose, r'"0\.0\.0\.0:8984:8080"')
        self.assertIn("redis:", compose)
        self.assertIn("solr:", compose)
        self.assertIn("fedora:", compose)
        self.assertIn("./solr/config:/opt/solr/server/solr/configsets/hydra-development:ro", compose)
        self.assertNotIn("configsets/_default", compose)

    def test_solr_hyrax_configuration_is_present(self):
        self.assertTrue((PROJECT_ROOT / "solr/config/schema.xml").is_file())
        self.assertTrue((PROJECT_ROOT / "solr/config/solrconfig.xml").is_file())

    def test_docker_build_prepares_universal_viewer_paths(self):
        dockerfile = (PROJECT_ROOT / "Dockerfile").read_text()

        self.assertIn("COPY config/uv ./config/uv", dockerfile)
        self.assertIn("mkdir -p public/uv", dockerfile)

    def test_javascript_git_dependencies_are_reachable_without_ssh_keys(self):
        package = json.loads(PACKAGE_FILE.read_text())
        shx = package["devDependencies"]["shx"]

        self.assertTrue(shx.startswith("git+https://"))
        self.assertNotIn("git+ssh://", shx)


if __name__ == "__main__":
    unittest.main()
