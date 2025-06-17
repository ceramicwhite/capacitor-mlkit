import { WebPlugin } from '@capacitor/core';

import type { 
  WhisperPlugin, 
  TranscribeFileOptions, 
  TranscribeResult, 
  LoadModelOptions, 
  ModelInfo, 
  IsSupportedResult, 
  PermissionStatus
} from './definitions';

export class WhisperWeb extends WebPlugin implements WhisperPlugin {
  async transcribeFile(_options: TranscribeFileOptions): Promise<TranscribeResult> {
    console.warn('Whisper transcription is not available on web. Consider using a cloud-based solution or WebAssembly implementation.');
    throw this.unimplemented('Not implemented on web. Use the native iOS/Android implementation for optimal performance.');
  }

  async loadModel(_options: LoadModelOptions): Promise<void> {
    console.warn('Model loading is not available on web.');
    throw this.unimplemented('Not implemented on web.');
  }

  async unloadModel(): Promise<void> {
    console.warn('Model unloading is not available on web.');
    throw this.unimplemented('Not implemented on web.');
  }

  async getModelInfo(): Promise<ModelInfo> {
    console.warn('Model info is not available on web.');
    throw this.unimplemented('Not implemented on web.');
  }

  async isSupported(): Promise<IsSupportedResult> {
    return {
      supported: false,
      coreMLSupported: false,
    };
  }

  async checkPermissions(): Promise<PermissionStatus> {
    // On web, we can check for microphone permissions using the Web API
    if (navigator.permissions && navigator.permissions.query) {
      try {
        const result = await navigator.permissions.query({ name: 'microphone' as PermissionName });
        return {
          microphone: result.state,
        };
      } catch (error) {
        console.warn('Unable to check microphone permissions:', error);
      }
    }

    return {
      microphone: 'prompt',
    };
  }

  async requestPermissions(): Promise<PermissionStatus> {
    // On web, we request microphone permissions by attempting to access getUserMedia
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      // Stop the stream immediately as we only needed to request permission
      stream.getTracks().forEach(track => track.stop());
      return {
        microphone: 'granted',
      };
    } catch (error) {
      console.warn('Unable to request microphone permissions:', error);
      return {
        microphone: 'denied',
      };
    }
  }
}