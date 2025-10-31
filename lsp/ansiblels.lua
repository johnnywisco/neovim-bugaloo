return {
    cmd = { "ansible-language-server", "--stdio" },
    filetypes = { "yaml.ansible" },
    root_markers = {
        "ansible.cfg",
        ".ansible-lint",
        ".git",
    },
    setting = {
        ansible = {
            ansible = {
                -- path = "ansible"
                path = "/home/johnny/.local/share/uv/tools/ansible-dev-tools/bin/ansible"
            },
            executionEnvironment = {
                enabled = false
            },
            python = {
                interpreterPath = "python"
            },
            validation = {
                enabled = true,
                lint = {
                    enabled = true,
                    path = "/home/johnny/.local/share/uv/tools/ansible-dev-tools/bin/ansible-lint"
                },
            },
        },
    },
}
