class GrpcClient < Formula
  desc "Homebrew Package for a GRPC client to query the server with integrated React UI"
  homepage "https://bhagwati-web.github.io/grpc-client/"
  license "MIT"
  version "0.0.1"
  repository "https://github.com/bhagwati-web/grpc-client/releases/download/#{version}"
  @@server_port = "50051"
  @@server_url = "http://localhost:#{@@server_port}"

  on_macos do
    if Hardware::CPU.intel?
      url "#{repository}/grpc-client-darwin-amd64"
      sha256 "4c5836e38715c919ea27b649f9bfae028b31afe9416ac60c57ebe488eefaf7d9"
    else
      url "#{repository}/grpc-client-darwin-arm64"
      sha256 "81fe1a1e2b05ca8c3d2995feebbd3a1d88e3a95e743bdd670382f1095a586e70"
    end
  end

  on_linux do
    url "#{repository}/grpc-client-linux-amd64"
    sha256 "19b20ce3293dc9ec102fde47fb33a9050d4a0c85efdfbefa342a73fe54dd1582"
  end


  # Go binary has no external dependencies - works without Go installed!

  def install
    # Stop any running grpc-client processes before installation
    system "echo 'Checking for running GRPC Client processes...'"
    
    # Try to stop using the standard grpcstop command if it exists
    if File.exist?("#{HOMEBREW_PREFIX}/bin/grpcstop")
      system "#{HOMEBREW_PREFIX}/bin/grpcstop 2>/dev/null || true"
    end
    
    # Kill any processes using the PID file
    if File.exist?(File.expand_path("~/.grpc-client.pid"))
      pid = File.read(File.expand_path("~/.grpc-client.pid")).strip
      system "kill #{pid} 2>/dev/null || true"
      system "rm -f ~/.grpc-client.pid 2>/dev/null || true"
    end
    
    # Kill any processes using the port as fallback
    system "lsof -t -i:#{@@server_port} 2>/dev/null | xargs kill -9 2>/dev/null || true"
    
    # Kill any grpc-client processes by name
    system "pkill -f grpc-client 2>/dev/null || true"
    
    system "echo 'Installing new GRPC Client version...'"
    
    # Rename the downloaded binary to a standard name
    bin.install Dir["*"].first => "grpc-client"
    
    (bin/"grpcstart").write <<~EOS
      #!/bin/bash

      echo "Starting GRPC Client Server with integrated React UI..."
      
      # Start the GRPC client in background
      nohup #{bin}/grpc-client > /dev/null 2>&1 &
      GRPC_PID=$!
      
      # Save PID for later stopping
      echo $GRPC_PID > ~/.grpc-client.pid
      
      # Allow time for the server to start
      sleep 3

      echo "GRPC Client Server started successfully!"
      echo "Server is running on #{@@server_url}"
      echo "React UI is available at #{@@server_url}"
      echo "Use 'grpcstop' to stop the server"

      # Open the default browser with the server URL
      if command -v xdg-open > /dev/null; then
        xdg-open "#{@@server_url}"
      elif command -v open > /dev/null; then
        open "#{@@server_url}"
      else
        echo "Please open #{@@server_url} in your browser"
      fi
    EOS
    (bin/"grpcstop").write <<~EOS
      #!/bin/bash
      
      echo "Stopping GRPC Client Server..."
      
      # Try to kill using saved PID first
      if [ -f ~/.grpc-client.pid ]; then
        PID=$(cat ~/.grpc-client.pid)
        if ps -p $PID > /dev/null 2>&1; then
          kill $PID
          echo "Stopped GRPC Client Server (PID: $PID)"
        fi
        rm -f ~/.grpc-client.pid
      fi
      
      # Fallback: kill any process using the port
      if lsof -t -i:#{@@server_port} > /dev/null 2>&1; then
        lsof -t -i:#{@@server_port} | xargs kill -9
        echo "Killed any remaining processes on port #{@@server_port}"
      fi
      
      echo "GRPC Client Server stopped successfully!"
    EOS
    
    # Make scripts executable
    chmod 0755, bin/"grpcstart"
    chmod 0755, bin/"grpcstop"
  end
  
  def post_install
    puts "\n\n\n================================================"
    puts "GRPC Client installed successfully!"
    puts ""
    puts "The server includes:"
    puts "  • gRPC client API"
    puts "  • Integrated React UI"
    puts "  • Collection management"
    puts "  • Server reflection"
    puts ""
    puts "🚀 Start server:    grpcstart"
    puts "🛑 Stop server:     grpcstop"
    puts ""
    puts "Server will be available at: #{@@server_url}"
    puts "================================================"
    puts ""
    puts "🎉 Starting GRPC Client Server automatically..."
    puts ""
    
    # Automatically start the server after installation
    system "#{bin}/grpcstart"
    
    puts "\n\n"
  end
end
