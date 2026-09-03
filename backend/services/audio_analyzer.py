import torch
import librosa
import numpy as np
from transformers import AutoFeatureExtractor, AutoModelForAudioClassification

MODEL_NAME = 'Dpngtm/wav2vec2-emotion-recognition'

class EmotionRecognizer:
    def __init__(self):
        print('Loading audio emotion model...')
        self.feature_extractor = AutoFeatureExtractor.from_pretrained(MODEL_NAME)
        self.model = AutoModelForAudioClassification.from_pretrained(MODEL_NAME)
        self.model.eval()
        self.labels = {int(k): v.lower() for k, v in self.model.config.id2label.items()}
        print('Audio model loaded.')
        print('Labels:', self.labels)

    def predict_chunk(self, audio):
        inputs = self.feature_extractor(audio, sampling_rate=16000, return_tensors='pt')
        with torch.no_grad():
            outputs = self.model(**inputs)
        probabilities = torch.softmax(outputs.logits, dim=-1)[0]
        return probabilities.cpu().numpy()

    def predict(self, audio_path):
        audio, _ = librosa.load(audio_path, sr=16000, mono=True)
        audio, _ = librosa.effects.trim(audio, top_db=30)
        if len(audio) <= 10 * 16000:
            chunks = [audio]
        else:
            chunk_size = 5 * 16000
            chunks = [audio[start:start + chunk_size] for start in range(0, len(audio), chunk_size) if len(audio[start:start + chunk_size]) >= 16000]
            if not chunks:
                chunks = [audio]
        predictions = [self.predict_chunk(chunk) for chunk in chunks]
        mean_probabilities = np.mean(predictions, axis=0)
        results = {self.labels[i]: round(float(p), 4) for i, p in enumerate(mean_probabilities)}
        dominant = max(results, key=results.get)
        return {'dominant_emotion': dominant, 'confidence': results[dominant], 'probabilities': results, 'chunks_analyzed': len(chunks)}

recognizer = EmotionRecognizer()
