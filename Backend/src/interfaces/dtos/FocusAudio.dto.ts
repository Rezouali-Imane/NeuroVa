export interface CreateFocusAudioDTO {
  sessionid: string; 
  volumelevel?: number; 
  mixambientsounds?: boolean;  
  sounds?: CreateAmbientSoundDTO[]; 
}

export interface CreateAmbientSoundDTO {
  soundid?: string;
  name: string; 
  audiourl?: string; 
  islooping?: boolean; 
}

export interface UpdateFocusAudioSettingsDTO {
  volumelevel?: number;
  mixambientsounds?: boolean;
}

export interface DeleteAmbientSoundDTO {
    soundid: string;
}