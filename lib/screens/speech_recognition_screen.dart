import 'package:flutter/material.dart';
import 'dart:io';
import '../services/integrated_speech_service.dart';

/// Example widget showing how to use the IntegratedSpeechService
class SpeechRecognitionScreen extends StatefulWidget {
  const SpeechRecognitionScreen({Key? key}) : super(key: key);

  @override
  State<SpeechRecognitionScreen> createState() => _SpeechRecognitionScreenState();
}

class _SpeechRecognitionScreenState extends State<SpeechRecognitionScreen> {
  final IntegratedSpeechService _speechService = IntegratedSpeechService();
  
  String _bengaliText = '';
  String _englishText = '';
  bool _isRecording = false;
  bool _isProcessing = false;
  String _status = 'Ready to record';

  @override
  void dispose() {
    _speechService.dispose();
    super.dispose();
  }

  /// Handles the record button press
  Future<void> _handleRecordButton() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  /// Starts audio recording
  Future<void> _startRecording() async {
    setState(() {
      _status = 'Checking permissions...';
      _bengaliText = '';
      _englishText = '';
    });

    final hasPermission = await _speechService.hasPermission();
    if (!hasPermission) {
      setState(() {
        _status = 'Microphone permission denied';
      });
      _showError('Please grant microphone permission in settings');
      return;
    }

    final started = await _speechService.startRecording();
    if (started) {
      setState(() {
        _isRecording = true;
        _status = 'Recording... (Speak in Bengali)';
      });
    } else {
      setState(() {
        _status = 'Failed to start recording';
      });
      _showError('Could not start recording. Please try again.');
    }
  }

  /// Stops recording and transcribes the audio
  Future<void> _stopRecording() async {
    setState(() {
      _status = 'Stopping recording...';
      _isRecording = false;
    });

    final audioFile = await _speechService.stopRecording();
    
    if (audioFile == null) {
      setState(() {
        _status = 'Recording failed';
      });
      _showError('Could not save recording. Please try again.');
      return;
    }

    await _transcribeAudio(audioFile);
  }

  /// Transcribes the audio file using OpenAI Whisper
  Future<void> _transcribeAudio(File audioFile) async {
    setState(() {
      _isProcessing = true;
      _status = 'Transcribing with OpenAI Whisper...';
    });

    try {
      final result = await _speechService.transcribeAudioFileBoth(audioFile);
      
      setState(() {
        _bengaliText = result['bengali'] ?? '';
        _englishText = result['english'] ?? '';
        _isProcessing = false;
        
        if (_bengaliText.isEmpty && _englishText.isEmpty) {
          _status = 'No speech detected. Please try again.';
        } else {
          _status = 'Transcription complete!';
        }
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _status = 'Error: ${e.toString()}';
      });
      _showError('Transcription failed. Please check your API key and internet connection.');
    }
  }

  /// Shows an error dialog
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bengali Speech Recognition'),
        backgroundColor: Colors.teal,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Card
              Card(
                color: _isRecording ? Colors.red.shade50 : Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        _isRecording ? Icons.mic : Icons.mic_none,
                        color: _isRecording ? Colors.red : Colors.blue,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _status,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Record Button
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _handleRecordButton,
                icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                label: Text(
                  _isRecording ? 'Stop Recording' : 'Start Recording',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRecording ? Colors.red : Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Results Section
              if (_bengaliText.isNotEmpty || _englishText.isNotEmpty)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Bengali Text
                        if (_bengaliText.isNotEmpty) ...[
                          const Text(
                            'Bengali (বাংলা):',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SelectableText(
                                _bengaliText,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        
                        // English Translation
                        if (_englishText.isNotEmpty) ...[
                          const Text(
                            'English Translation:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SelectableText(
                                _englishText,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              
              // Processing Indicator
              if (_isProcessing)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Processing with OpenAI Whisper...',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}