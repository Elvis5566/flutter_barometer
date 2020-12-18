package co.velodash.flutter_barometer

import android.content.Context.SENSOR_SERVICE
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterBarometerPlugin */
class FlutterBarometerPlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler, SensorEventListener {

    private val TAG = "FlutterBarometerPlugin"
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var sensorManager: SensorManager? = null
    private var sensor: Sensor? = null
    private var sink: EventChannel.EventSink? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_barometer/method")
        methodChannel.setMethodCallHandler(this)
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "flutter_barometer/event")
        eventChannel.setStreamHandler(this)
        sensorManager = flutterPluginBinding.applicationContext.getSystemService(SENSOR_SERVICE) as? SensorManager
        sensor = sensorManager?.getDefaultSensor(Sensor.TYPE_PRESSURE)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "isValid") {
            result.success(sensor != null)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        sensorManager = null
        sensor = null
        sink = null
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        Log.d(TAG, "onListen")
        val sensor = this.sensor
        val sensorManager = this.sensorManager
        if (events == null || sensor == null || sensorManager == null) {
            return
        }
        sensorManager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_NORMAL)
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        Log.d(TAG, "onCancel")
        val index = arguments as? Int
        val sensor = this.sensor
        val sensorManager = this.sensorManager
        if (index == null || sensor == null || sensorManager == null) {
            return
        }
        sensorManager.unregisterListener(this)
        sink = null
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event?.values == null || event.values.isEmpty()) {
            return
        }

        val result = hashMapOf<String, Any>(
                "pressure" to event.values[0],
                "altitude" to SensorManager.getAltitude(SensorManager.PRESSURE_STANDARD_ATMOSPHERE, event.values.first())
        )
        sink?.success(result)
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
    }
}
