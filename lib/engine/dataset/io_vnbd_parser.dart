import 'dart:math' as math;
import 'package:latlong2/latlong.dart';
import 'package:vector_math/vector_math_64.dart';

/// Single telemetry frame from the IO-VNBD Benchmark Dataset
class IoVnbdFrame {
  final double timestampMs;
  final Vector3 rawAccel;      // Phone Accelerometer (m/s^2)
  final Vector3 rawGyro;       // Phone Gyroscope (rad/s)
  final LatLng? gnssPosition;   // GNSS Lat/Lon (null during tunnel outage)
  final double gnssSpeedMs;    // GNSS Speed (m/s)
  final double hdop;           // Horizontal Dilution of Precision
  final int satCount;          // Satellite Count
  final LatLng groundTruth;    // True Vehicle Position for evaluation
  final bool isTunnelZone;     // True if frame is inside GNSS blackout zone

  IoVnbdFrame({
    required this.timestampMs,
    required this.rawAccel,
    required this.rawGyro,
    this.gnssPosition,
    required this.gnssSpeedMs,
    required this.hdop,
    required this.satCount,
    required this.groundTruth,
    required this.isTunnelZone,
  });
}

/// Parser and Simulator for IO-VNBD Ground Vehicle Benchmark Dataset
class IoVnbdParser {
  /// Generate a high-fidelity synthetic IO-VNBD dataset trajectory (50Hz sensor stream)
  /// simulating a vehicle driving through an urban highway tunnel with GNSS blackout.
  static List<IoVnbdFrame> generateBenchmarkDataset() {
    List<IoVnbdFrame> frames = [];
    
    // Starting coordinates (e.g. Pragati Maidan Tunnel / Connaught Place corridor)
    double startLat = 28.6139;
    double startLon = 77.2090;
    
    double currentSpeedMs = 13.88; // ~50 km/h constant cruising speed
    double dt = 0.02; // 50Hz IMU sampling frequency (20ms)
    
    int totalFrames = 1500; // 30 seconds of driving data
    
    // Tunnel outage between frame 400 and 1100 (~14 seconds = ~200 meters tunnel)
    int tunnelStartFrame = 400;
    int tunnelEndFrame = 1100;

    double currLat = startLat;
    double currLon = startLon;
    double currHeadingRad = 0.785; // Driving North-East (45 degrees)

    math.Random rand = math.Random(42); // Deterministic seed for reproducible evaluation

    for (int i = 0; i < totalFrames; i++) {
      double timeMs = i * 20.0;
      bool isTunnel = (i >= tunnelStartFrame && i <= tunnelEndFrame);

      // Vehicle Kinematics with slight turns & acceleration harmonics
      if (i > 200 && i < 350) currHeadingRad += 0.001; // Gentle right curve
      if (i > 700 && i < 850) currHeadingRad -= 0.001; // Gentle left curve inside tunnel

      // Ground Truth Step
      double dNorth = currentSpeedMs * math.cos(currHeadingRad) * dt;
      double dEast = currentSpeedMs * math.sin(currHeadingRad) * dt;

      double dLat = dNorth / 111111.0;
      double dLon = dEast / (111111.0 * math.cos(currLat * math.pi / 180.0));

      currLat += dLat;
      currLon += dLon;

      LatLng groundTruth = LatLng(currLat, currLon);

      // Synthetic IMU Noise & Engine Harmonics (12Hz vibration + pothole at frame 750)
      double vibrationX = 0.2 * math.sin(2 * math.pi * 12.0 * (timeMs / 1000.0));
      double vibrationY = 0.15 * math.cos(2 * math.pi * 12.0 * (timeMs / 1000.0));
      double vibrationZ = 0.3 * math.sin(2 * math.pi * 15.0 * (timeMs / 1000.0));

      double potholeZ = (i == 750) ? 6.5 : 0.0; // Simulated pothole shock in tunnel

      Vector3 rawAccel = Vector3(
        0.12 + vibrationX + (rand.nextDouble() - 0.5) * 0.1, // Forward accel + noise
        0.02 + vibrationY + (rand.nextDouble() - 0.5) * 0.08,
        9.81 + vibrationZ + potholeZ + (rand.nextDouble() - 0.5) * 0.1, // Gravity + shock
      );

      Vector3 rawGyro = Vector3(
        (rand.nextDouble() - 0.5) * 0.02,
        (rand.nextDouble() - 0.5) * 0.02,
        (i > 200 && i < 350 ? 0.05 : (i > 700 && i < 850 ? -0.05 : 0.0)) + (rand.nextDouble() - 0.5) * 0.01,
      );

      // GNSS Metrics (degredation / drop inside tunnel)
      LatLng? gnssPos;
      double gnssSpeed = currentSpeedMs;
      double hdop = isTunnel ? 8.5 : 0.9 + rand.nextDouble() * 0.3;
      int satCount = isTunnel ? 1 : 14;

      if (!isTunnel) {
        // Add typical 1.5m GNSS jitter
        double gnssJitterLat = (rand.nextDouble() - 0.5) * 0.000015;
        double gnssJitterLon = (rand.nextDouble() - 0.5) * 0.000015;
        gnssPos = LatLng(currLat + gnssJitterLat, currLon + gnssJitterLon);
      } else {
        gnssPos = null; // Complete GNSS Blackout
      }

      frames.add(IoVnbdFrame(
        timestampMs: timeMs,
        rawAccel: rawAccel,
        rawGyro: rawGyro,
        gnssPosition: gnssPos,
        gnssSpeedMs: gnssSpeed,
        hdop: hdop,
        satCount: satCount,
        groundTruth: groundTruth,
        isTunnelZone: isTunnel,
      ));
    }

    return frames;
  }
}
