class Granted < Formula
  desc "Grant matching tool for finding funding opportunities"
  homepage "https://github.com/KurtLehnardt/granted"
  url "https://github.com/KurtLehnardt/granted.git",
      tag:    "v1.0.1",
      branch: "main"
  license "MIT"

  depends_on "node@22" => :build

  def install
    scaffold_dir = buildpath/"scaffold"

    # Build from the scaffold directory
    cd scaffold_dir

    # Install dependencies
    system "npm", "ci"

    # Install the entire scaffold directory (including dotfiles like .next,
    # if present) to libexec, excluding "." and "..".
    dot_skip = [".", ".."]
    dotfiles = Dir["#{scaffold_dir}/.*"].reject { |p| dot_skip.include?(File.basename(p)) }
    libexec.install Dir["#{scaffold_dir}/*"], dotfiles

    # Create a simple executable wrapper that respects PORT env var.
    # `npm run dev` already passes -H 127.0.0.1 (scaffold/package.json), so
    # the wrapper only needs to set PORT and exec it.
    (bin/"granted").write <<~EOS
      #!/bin/bash
      export PATH="#{libexec}/node_modules/.bin:$PATH"
      export PORT="${PORT:-3000}"
      cd #{libexec}
      exec npm run dev
    EOS
    (bin/"granted").chmod 0755
  end

  def caveats
    <<~EOS
      For the full experience (auto-update, menu bar integration), consider
      using the native installers from:
        https://github.com/KurtLehnardt/granted/releases

      To start Granted:
        granted

      Then open your browser to: http://localhost:3000
      (set PORT=xxxx before running `granted` to use a different port)
    EOS
  end

  test do
    assert_path_exists libexec/"node_modules"
    assert_path_exists libexec/"package.json"
  end
end
