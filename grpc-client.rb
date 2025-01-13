class GrpcClient < Formula
  desc "Homebrew Package for a GRPC client to query the server"
  homepage "https://bhagwati-web.github.io/homebrew-grpc-client"
  
  version "1.0.0"
  @@jar_file = "grpc-client-#{version}.jar"
  @@sha256 = "a0c2e0a27b256bfba3b355b643006253465977ce0b7d935bfb3ce92b6e615613"
  @@server_url = "http://localhost:8080"
  @@server_port = "50051"

  url "https://github.com/bhagwati-web/grpc-client/releases/download/#{version}/#{@@jar_file}"
  sha256 @@sha256
  license "MIT"

  depends_on "openjdk@17"
  depends_on "grpcurl"

  def install
    libexec.install @@jar_file
    (bin/"grpc-start").write <<~EOS
      #!/bin/bash
      exec java -jar #{libexec}/#{@@jar_file} start "$@"
      
      # Wait a moment for the server to start
      sleep 5

      # Open the default browser with the address
      if command -v xdg-open > /dev/null; then
        xdg-open "#{@@server_url}"
      else
        open "#{@@server_url}"
      fi
    EOS
    (bin/"grpc-stop").write <<~EOS
      #!/bin/bash
      exec lsof -t -i:#{@@server_port} | xargs kill -9 "$@"
    EOS
  end
  
  def post_install
    system "echo", "================================================"
    system "echo", "GRPC Client installed. Use 'grpc-start' and 'grpc-stop' to manage the server."
    system "echo", "The server will be available on #{@@server_url} and listening on port #{@@server_port}."
    system "echo", "================================================"
  end
end
