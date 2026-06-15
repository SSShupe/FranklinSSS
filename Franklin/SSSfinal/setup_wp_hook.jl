#!/usr/bin/env julia
# One-time setup: installs the WordPress post-commit hook.
# Run once after cloning on any machine:
#   julia setup_wp_hook.jl

repo_root = chomp(read(`git rev-parse --show-toplevel`, String))
hook_src = joinpath(repo_root, "Franklin", "SSSfinal", "hooks", "post-commit")
hook_dst = joinpath(repo_root, ".git", "hooks", "post-commit")
script = joinpath(repo_root, "Franklin", "SSSfinal", "publish_to_wp.jl")

cp(hook_src, hook_dst; force=true)
chmod(hook_dst, 0o755)
println("Hook installed.")

if !isfile(script)
  println("""

IMPORTANT: publish_to_wp.jl is missing.
This file contains your WordPress credentials and is intentionally
not stored in git. Copy it from your other machine to:
  $script""")
end
