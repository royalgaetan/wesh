package com.wesh.android

import android.content.Intent
import android.content.Intent.FLAG_ACTIVITY_NEW_TASK
import android.os.Bundle
import com.hover.sdk.api.Hover
import com.hover.sdk.api.HoverParameters
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {

    private fun SendMoney(PhoneNumber: String?, amount: String?) {
        try {
            Hover.initialize(this)
            Log.d("MainActivity", "Sims are = " + Hover.getPresentSims(this))
            Log.d("MainActivity", "Hover actions are = " + Hover.getAllValidActions(this))
        } catch (e: Exception) {
            Log.e("MainActivity", "hover exception", e)
        }

        // add your action Id from dashboard
        val i: Intent =
                HoverParameters.Builder(this)
                        .request("action_id")
                        .extra("PhoneNumber", PhoneNumber)
                        .extra("Amount", amount)
                        .buildIntent()
        startActivityForResult(i, 0)
    }

    override fun onCreate(savedInstanceState: Bundle?) {

        if (intent.getIntExtra("org.chromium.chrome.extra.TASK_ID", -1) == this.taskId) {
            this.finish()
            intent.addFlags(FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
        }
        super.onCreate(savedInstanceState)

        MethodChannel(getFlutterEngine()!!.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler { call, result ->
                    // Get arguments from flutter code
                    val arguments: Map<String, Any>? = call.arguments()
                    val PhoneNumber = arguments!!["phoneNumber"] as String?
                    val amount = arguments["amount"] as String?
                    if (call.method.equals("mtn_momo_send_money")) {
                        SendMoney(PhoneNumber, amount)
                        val response = "sent"
                        result.success(response)
                    }
                }
    }

    companion object {
        // Hover Action function
        private const val CHANNEL = "wesh/hover"
    }
}
