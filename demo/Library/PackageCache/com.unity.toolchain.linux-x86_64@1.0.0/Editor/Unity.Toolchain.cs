using System;
using System.IO;
using System.Collections.Generic;
using UnityEngine;
using NiceIO.Sysroot;
using UnityEditor.Il2Cpp;

namespace UnityEditor.Il2Cpp
{
    /// <summary>
    /// Toolchain package for building Linux x86_64 targets on Linux x86_64 host
    /// </summary>
    public class ToolchainLinuxX86_64: SysrootLinuxX86_64
    {
        private string _packageName           => "com.unity.toolchain.linux-x86_64";
        /// <summary>
        /// Name of package
        /// </summary>
        public override string Name           => _packageName;
        /// <summary>
        /// Name of host platform
        /// </summary>
        public override string HostPlatform   => "linux";
        /// <summary>
        /// Name of host architecture
        /// </summary>
        public override string HostArch       => "x86_64";
        /// <summary>
        /// Name of target platform
        /// </summary>
        public override string TargetPlatform => "linux";
        /// <summary>
        /// Name of target architecture
        /// </summary>
        public override string TargetArch     => "x86_64";

        private string _payloadVersion => "9.0.1-7.7.1908-v0_9c1c26d5205c7ead3cba5a545796579d753c459ac5e16d0690d1b087efa7835d";
        private string _payloadDir;

        /// <summary>
        /// Initialize toolchain package
        /// </summary>
        public ToolchainLinuxX86_64()
            : base()
        {
            _payloadDir = $"linux-x86/{_payloadVersion}";
            RegisterPayload(_packageName, _payloadDir);
        }

        /// <summary>
        /// Supplies arguments to il2cpp.exe
        /// </summary>
        /// <returns>The next argument to il2cpp.exe</returns>
        public override IEnumerable<string> GetIl2CppArguments()
        {
            var toolpath = PayloadInstallDirectory(_payloadDir);
            var linkerpath = toolpath.Combine("bin/ld.lld");
            var target = "x86_64-glibc2.17-linux-gnu";

            yield return $"--sysroot-path={SysrootInstallDirectory()}";
            yield return $"--compiler-flags=\"-target {target}\"";
            yield return $"--tool-chain-path={toolpath.InQuotes()}";
            yield return $"--linker-flags=\"-fuse-ld={linkerpath.InQuotes()} -target {target} -static-libstdc++\"";
        }
    }
}
