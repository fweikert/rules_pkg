# Copyright 2021 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Rules to aid TreeArtifact testing"""

def _directory_impl(ctx):
    out_dir_file = ctx.actions.declare_directory(ctx.attr.outdir or ctx.attr.name)

    args = ctx.actions.args()
    args.add(out_dir_file.path)

    for fn in ctx.attr.filenames:
        args.add(fn)
        args.add(ctx.attr.contents)

    ctx.actions.run(
        outputs = [out_dir_file],
        inputs = [],
        executable = ctx.executable._dir_creator,
        arguments = [args],
    )
    return DefaultInfo(files = depset([out_dir_file]))

directory = rule(
    doc = """Helper rule to create simple TreeArtifact structures

We would normally just use genrules for this, but their directory output
creation capabilities are "unsound".
    """,
    implementation = _directory_impl,
    attrs = {
        "filenames": attr.string_list(
            doc = """Paths to create in the directory.

Paths containing directories will also have the intermediate directories created too.""",
        ),
        "contents": attr.string(),
        "outdir": attr.string(),
        "_dir_creator": attr.label(
            default = ":create_directory_with_contents",
            executable = True,
            cfg = "exec",
        ),
    },
)