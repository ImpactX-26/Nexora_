package com.leads.cybersecurity

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import com.leads.cybersecurity.data.repository.MockSecurityRepository
import com.leads.cybersecurity.ui.navigation.LeadsNavHost
import com.leads.cybersecurity.ui.theme.CyberBackground
import com.leads.cybersecurity.ui.theme.LEADSTheme

class MainActivity : ComponentActivity() {

    private val securityRepository = MockSecurityRepository()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            LEADSTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = CyberBackground
                ) {
                    LeadsNavHost(repository = securityRepository)
                }
            }
        }
    }
}
