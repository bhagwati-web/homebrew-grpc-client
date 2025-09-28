class GrpcClient < Formula
  desc "Homebrew Package for a GRPC client to query the server with integrated React UI"
  homepage "https://bhagwati-web.github.io/grpc-client/"
  license "MIT"
  version "0.0.4"
  @@repository = "https://github.com/bhagwati-web/grpc-client/releases/download/#{version}"
  @@server_port = "50051"
  @@server_url = "http://localhost:#{@@server_port}"

  on_macos do
    if Hardware::CPU.intel?
      url "#{@@repository}/grpc-client-darwin-amd64"
      sha256 "43a12fda92d564d0f33f1f8f5cd09ee19daefcd6be16d1ebaf0f797fe46befe5"
    else
      url "#{@@repository}/grpc-client-darwin-arm64"
      sha256 "b1dd62a52b97414eb2997c34f0287663586eeb0ed3c4d8cf33a8fe68a3979f4e"
    end
  end

  on_linux do
    url "#{@@repository}/grpc-client-linux-amd64"
    sha256 "c670b6aa27063d40458076dd04ae8164976d1e869263ebf82a36d490c682f5ab"
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
