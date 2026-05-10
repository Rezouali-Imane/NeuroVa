export interface CreateFocusAudioDTO {
  sessionid: string; 
  volumelevel?: number; 
  mixmultiplesounds?: boolean;  
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
  mixmultiplesounds?: boolean;
}

export interface DeleteAmbientSoundDTO {
    soundid: string;
}

export interface DeleteFocusAudioSettingsDTO {
  settingsid: string;
}