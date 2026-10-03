
package com.elysian.ananda

import com.ryanheise.audioservice.AudioServiceActivity

// audio_service 0.18.x requires AudioServiceActivity instead of FlutterActivity.
// This gives the background audio service access to the correct FlutterEngine.
class MainActivity : AudioServiceActivity()
