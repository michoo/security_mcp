# Security MCP Server

## Objectives
This repository is a simple MCP server's PoC to test and evaluate the **Model Context Protocol (MCP)** technology and integration. 
It facilitated the assessment of integrating security tools within an IDE environment and demonstrated the advantages of leveraging generative AI to support remediation workflows based on report findings.
## What is MCP?

The **Model Context Protocol (MCP)** is a standard that streamlines interaction between AI models and various tools via a client-server architecture:

- **MCP Clients** (e.g., VSCode) connect to **MCP Servers** to request actions on behalf of the model.
- **MCP Servers** provide tools with defined functionalities using a clear and structured interface.
- **MCP** standardizes communication through message protocols for tool discovery, invocation, and response handling.

**Example Use Case:**  
A file system MCP server might enable interaction with tools for reading, writing, or searching files and directories. Analogously, GitHub's MCP server can list repositories, create pull requests, or manage issues.

By standardizing model-tool interactions, MCP eliminates the need for custom integrations between each model and each tool. It also extends the capabilities of your AI assistant by allowing new MCP servers to integrate seamlessly into your workspace.

👉 For more details, explore the [Model Context Protocol specification](https://modelcontextprotocol.io/).

---

## Features
- **MCP Server** performing security scans:
  - **Secret detection**:
    - nosey parker
    - kingfisher (wip)
    - gitleaks
  - **SCA**:
    - trivy (that one includes IaC)
    - osv-scanner
    - sca fixes 
  - **SAST**:
    - opengrep
  - **DAST**:
    - nuclei
    - zaproxy
- Remediation suggestions based on findings and leveraging genAI
- **Guinea-pig project for testing**


---

## Examples
### Patch proposual

![MCP Example](mcp.png)

### Full test report and recommendations
![MCP Example analysis](analysis.png)

---



## Security in MCP Server

MCP implementations focus on security to provide safe interactions between tools, clients, and servers. However, **not all IDEs or MCP's server provide the same level of security**.

To learn more about security considerations for MCP, refer to:  
🔗 [Security Tips for VSCode Extensions and Copilot](https://code.visualstudio.com/docs/copilot/security)

---

## Installation

### Prerequisites
You’ll need the following tools and packages:
- [Python 3.12+](https://www.python.org/)
- [UV](https://github.com/python-poetry/poetry) package manager (already configured).

### Steps

1. **Set up the environment**:
   ```bash
   mkdir .venv
   uv sync
   ```
2. **Run the server**:
   ```bash
   uv run mcp_server.py
   # or
   source .venv/bin/activate
   python mcp_server.py
   ```
   Once the server is running, it will be available on:
   ```
   http://127.0.0.1:8000/mcp
   ```
3. **Configure your MCP client**:  
   Update the client settings to connect to the running MCP server.

---

## Debugging the MCP Server with a Web Inspector

If you wish to debug or inspect your MCP server, you can use the **MCP Inspector**:

```
npx @modelcontextprotocol/inspector
```

This launches a GUI-based tool for debugging and inspecting the behavior of your MCP server.

## Guinea-pig
This is a dedicated project to test the MCP server.

## IDE Compatibility and Recommendations

### **Visual Studio Code**

#### GitHub Copilot:
1. Authenticate with GitHub Copilot.
2. Open the **guinea-pig** project in VSCode.
3. Enable the extension:  
   Navigate to **Extensions → MCP Servers → Installed → Start Server.**

**Usability Note**: Results are functional, but the user experience might need more refinement.

#### Local Ollama Integration:
To use **Ollama** with VSCode, install the [Continue.dev](https://github.com/continue-dev/vscode-continue) plugin. Configuration is straightforward, but the experience might not be as seamless compared to Copilot.

---

### **Cursor IDE**

Cursor works well in building plans, applying changes, and delivering detailed feedback.  
👍 **Best IDE experience so far** in terms of usability and results!

---

### **PyCharm**

Currently, MCP servers using HTTP are **not compatible** with PyCharm.



## License

MIT License