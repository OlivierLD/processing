// Utility classes used in VL53L0X
class SequenceStep {
	boolean tcc, dss, msrc, preRange, finalRange;

	public SequenceStep tcc(boolean tcc) {
		this.tcc = tcc;
		return this;
	}
	public SequenceStep dss(boolean dss) {
		this.dss = dss;
		return this;
	}
	public SequenceStep msrc(boolean msrc) {
		this.msrc = msrc;
		return this;
	}
	public SequenceStep preRange(boolean preRange) {
		this.preRange = preRange;
		return this;
	}
	public SequenceStep finalRange(boolean finalRange) {
		this.finalRange = finalRange;
		return this;
	}
}

class SPADInfo {
  int count;
  boolean isAperture;

  public SPADInfo setCount(int count) {
    this.count = count;
    return this;
  }
  public SPADInfo setAperture(boolean aperture) {
    this.isAperture = aperture;
    return this;
  }
}

class SequenceStepTimeouts {
	int msrcDssTccMicrosec,
			preRangeMicrosec,
			finalRangeMicorsec,
			finalRangeVcselPeriodPclks,
			preRangeMclks;
	public SequenceStepTimeouts msrcDssTccMicrosec(int msrcDssTccMicrosec) {
		this.msrcDssTccMicrosec = msrcDssTccMicrosec;
		return this;
	}
	public SequenceStepTimeouts preRangeMicrosec(int preRangeMicrosec) {
		this.preRangeMicrosec = preRangeMicrosec;
		return this;
	}
	public SequenceStepTimeouts finalRangeMicorsec(int finalRangeMicorsec) {
		this.finalRangeMicorsec = finalRangeMicorsec;
		return this;
	}
	public SequenceStepTimeouts finalRangeVcselPeriodPclks(int finalRangeVcselPeriodPclks) {
		this.finalRangeVcselPeriodPclks = finalRangeVcselPeriodPclks;
		return this;
	}
	public SequenceStepTimeouts preRangeMclks(int preRangeMclks) {
		this.preRangeMclks = preRangeMclks;
		return this;
	}
}
