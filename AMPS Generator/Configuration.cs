namespace AMPS_Generator {
	public struct Configuration {
		internal static Configuration ASM68K = new Configuration() {
			Assembler = AssemblerInfo.ASM68K,
			Flags = ConfigFlags.Normal,
		};

		internal static Configuration AS = new Configuration() {
			Assembler = AssemblerInfo.AS,
			Flags = ConfigFlags.Normal,
		};

		internal AssemblerInfo Assembler;
		internal ConfigFlags Flags;
	}

	internal struct ConfigFlags {
		internal static ConfigFlags Normal = new ConfigFlags() {
			SAFE_PSGFREQ = 1, SFX_MASTERVOL = 0, MODULATION = 1, PORTAMENTO = 1,
			MODENV = 1, DACFMVOLENV = 1, UNDERWATER = 1, BACKUP = 1, SOUNDTEST = 1,
			BACKUPNOSFX = 1, FM6 = 1, PSG4 = 1, PSGADSR = 1, FM3SM = 1, MODTL = 1,
		};

		int SAFE_PSGFREQ, SFX_MASTERVOL, MODULATION, PORTAMENTO;
		int MODENV, DACFMVOLENV, UNDERWATER, BACKUP, SOUNDTEST;
		int BACKUPNOSFX, FM6, PSG4, PSGADSR, FM3SM, MODTL;

		public string Build() {
			return $"FEATURE_SAFE_PSGFREQ =\t{SAFE_PSGFREQ}\t; set to 1 to enable safety checks for PSG frequency. Some S3K SFX require this to be 0\n" +
				$"FEATURE_SFX_MASTERVOL =\t{SFX_MASTERVOL}\t; set to 1 to make SFX be affected by master volumes\n" +
				$"FEATURE_MODULATION =\t{MODULATION}\t; set to 1 to enable software modulation effect\n" +
				$"FEATURE_PORTAMENTO =\t{PORTAMENTO}\t; set to 1 to enable portamento effect\n" +
				$"FEATURE_MODENV =\t{MODENV}\t; set to 1 to enable modulation envelopes\n" +
				$"FEATURE_DACFMVOLENV =\t{DACFMVOLENV}\t; set to 1 to enable volume envelopes for FM & DAC channels\n" +
				$"FEATURE_UNDERWATER =\t{UNDERWATER}\t; set to 1 to enable underwater mode flag\n" +
				$"FEATURE_BACKUP =\t{BACKUP}\t; set to 1 to enable back-up channels. Used for the 1-up sound in Sonic 1, 2 and 3K\n" +
				$"FEATURE_BACKUPNOSFX =\t{BACKUPNOSFX}\t; set to 1 to disable SFX while a song is backed up. Used for the 1-up sound\n" +
				$"FEATURE_FM6 =\t\t{FM6}\t; set to 1 to enable FM6 to be used in music\n" +
				$"FEATURE_PSG4 =\t\t{PSG4}\t; set to 1 to enable a separate PSG4 channel\n" +
				$"FEATURE_PSGADSR =\t{PSGADSR}\t; set to 1 to enable ADSR for PSG\n" +
				$"FEATURE_FM3SM =\t\t{FM3SM}\t; set to 1 to enable FM3 Special Mode support\n" +
				$"FEATURE_MODTL =\t\t{MODTL}\t; set to 1 to enable TL modulation feature\n" +
				$"FEATURE_SOUNDTEST =\t{SOUNDTEST}\t; set to 1 to enable changes which make AMPS compatible with custom sound test";
		}
	}
}