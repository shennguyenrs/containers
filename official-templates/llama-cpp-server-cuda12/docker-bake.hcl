variable "LLAMA_CPP_VERSION" {
  default = "b8882"
}

group "default" {
  targets = ["llama-cpp-server"]
}

target "llama-cpp-server" {
  context = "official-templates/llama-cpp-server-cuda12"
  dockerfile = "Dockerfile"
  platforms = ["linux/amd64"]
  contexts = {
    scripts = "container-template"
    proxy   = "container-template/proxy"
    logo    = "container-template"
  }
  args = {
    BASE_IMAGE = "ghcr.io/ggml-org/llama.cpp:server-cuda12-${LLAMA_CPP_VERSION}"
  }
  tags = [
    "shennguyenrs/llama-cpp-server-cuda12:${LLAMA_CPP_VERSION}",
  ]
}
