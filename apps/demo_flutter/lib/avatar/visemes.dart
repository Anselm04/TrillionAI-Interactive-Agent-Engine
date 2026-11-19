enum Viseme { rest, closed, wide, open, round, teeth, tongue }

Viseme phonemeToViseme(String phoneme) {
  final p=phoneme.toUpperCase().replaceAll(RegExp(r'[012]$'),'');
  if (['P','B','M'].contains(p)) return Viseme.closed;
  if (['F','V'].contains(p)) return Viseme.teeth;
  if (['TH','DH','L'].contains(p)) return Viseme.tongue;
  if (['UW','UH','OW','OY','W'].contains(p)) return Viseme.round;
  if (['AA','AE','AH','AO','AW','AY','ER'].contains(p)) return Viseme.open;
  if (['IY','IH','EY','EH','S','Z','SH','ZH','CH','JH','T','D','N','R','K','G','NG','HH','Y'].contains(p)) return Viseme.wide;
  return Viseme.rest;
}
class MouthPose {
  final double opening, width;
  const MouthPose(this.opening,this.width);
  static MouthPose forViseme(Viseme v) => switch(v) {
    Viseme.rest => const MouthPose(.05,1),
    Viseme.closed => const MouthPose(0,1),
    Viseme.wide => const MouthPose(.28,1.35),
    Viseme.open => const MouthPose(1,1.05),
    Viseme.round => const MouthPose(.65,.55),
    Viseme.teeth => const MouthPose(.15,.9),
    Viseme.tongue => const MouthPose(.35,1.1),
  };
  MouthPose blend(MouthPose other,double t)=>MouthPose(opening+(other.opening-opening)*t,width+(other.width-width)*t);
}
class PhonemeCue {
  final int startMs,endMs;
  final String phoneme;
  const PhonemeCue(this.startMs,this.endMs,this.phoneme);
}
class VisemeTimeline {
  final List<PhonemeCue> cues;
  VisemeTimeline(List<PhonemeCue> input):cues=List.unmodifiable(input) {
    var end=0;
    for(final cue in cues){
      if(cue.startMs<end||cue.endMs<=cue.startMs)throw ArgumentError('Cues must be ordered, non-overlapping and positive duration');
      end=cue.endMs;
    }
  }
  MouthPose sample(int elapsedMs){
    final rest=MouthPose.forViseme(Viseme.rest);
    var lo=0,hi=cues.length;
    while(lo<hi){final mid=(lo+hi)~/2;if(cues[mid].endMs<=elapsedMs){lo=mid+1;}else{hi=mid;}}
    if(lo==cues.length||elapsedMs<cues[lo].startMs)return rest;
    final cue=cues[lo],pose=MouthPose.forViseme(phonemeToViseme(cue.phoneme));
    final before=lo>0&&cues[lo-1].endMs==cue.startMs?MouthPose.forViseme(phonemeToViseme(cues[lo-1].phoneme)):rest;
    final after=lo+1<cues.length&&cues[lo+1].startMs==cue.endMs?MouthPose.forViseme(phonemeToViseme(cues[lo+1].phoneme)):rest;
    final fade=((cue.endMs-cue.startMs)/2).clamp(1.0,35.0).toDouble();
    final fromStart=elapsedMs-cue.startMs,remaining=cue.endMs-elapsedMs;
    if(fromStart<fade)return before.blend(pose,.5+.5*fromStart/fade);
    if(remaining<fade)return pose.blend(after,.5*(1-remaining/fade));
    return pose;
  }
}
