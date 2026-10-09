package com.leads.cybersecurity.domain

import com.leads.cybersecurity.data.model.ThreatSeverity
import java.util.Locale

data class PhishingAnalysisVerdict(
    val inputQuery: String,
    val isPhishing: Boolean,
    val riskSeverity: ThreatSeverity,
    val riskScore: Int, // 0 to 100
    val detectedTactics: List<String>,
    val deceptiveIndicators: List<String>,
    val aiRecommendation: String,
    val cleanUrlPreview: String?
)

object HeuristicAnalyzer {

    private val SUSPICIOUS_TLDS = setOf(".xyz", ".top", ".buzz", ".icu", ".work", ".cfd", ".gq", ".ml", ".tk", ".ga")
    private val HIGH_RISK_KEYWORDS = listOf(
        "verify your identity", "account suspended", "immediate action required",
        "unauthorized transaction", "click here to claim", "urgent notice",
        "password expired", "lottery winner", "refund available", "update your kyc",
        "crypto giveaway", "unusual sign-in activity", "login now to prevent closure"
    )
    private val KNOWN_BRAND_IMPERSONATIONS = mapOf(
        "paypa1" to "PayPal",
        "paypai" to "PayPal",
        "netflix-update" to "Netflix",
        "amzn-" to "Amazon",
        "amazn" to "Amazon",
        "appleid-verify" to "Apple",
        "wellsfarg0" to "Wells Fargo",
        "chase-security" to "Chase Bank",
        "google-security-alert" to "Google"
    )

    fun analyzeTextOrUrl(rawInput: String): PhishingAnalysisVerdict {
        val input = rawInput.trim()
        val lower = input.lowercase(Locale.ROOT)
        val tactics = mutableListOf<String>()
        val indicators = mutableListOf<String>()
        var score = 5 // baseline safe

        // Check if URL or Text
        val isUrl = lower.startsWith("http://") || lower.startsWith("https://") || lower.contains(".com") || lower.contains(".org") || lower.contains(".net")

        if (lower.startsWith("http://")) {
            tactics.add("Insecure Protocol (HTTP)")
            indicators.add("Unencrypted HTTP communication exposes credentials in transit.")
            score += 25
        }

        // Check suspicious TLDs
        for (tld in SUSPICIOUS_TLDS) {
            if (lower.contains(tld)) {
                tactics.add("High-Risk Domain TLD ($tld)")
                indicators.add("Domain uses a top-level extension frequently abused for automated spam campaigns.")
                score += 30
                break
            }
        }

        // Check IP address in hostname (e.g. http://192.168.1.1/login)
        val ipRegex = Regex("""https?://\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}""")
        if (ipRegex.containsMatchIn(lower)) {
            tactics.add("Raw IP Address in URL")
            indicators.add("Direct IP address used instead of legitimate registered domain name.")
            score += 35
        }

        // Check Brand Impersonation / Typosquatting
        for ((fake, brand) in KNOWN_BRAND_IMPERSONATIONS) {
            if (lower.contains(fake)) {
                tactics.add("Brand Typosquatting ($brand Impersonation)")
                indicators.add("Look-alike domain crafted to deceive users into thinking this is official $brand.")
                score += 45
                break
            }
        }

        // Check Urgency / Social Engineering Keywords
        for (keyword in HIGH_RISK_KEYWORDS) {
            if (lower.contains(keyword)) {
                tactics.add("Urgency & Fear Tactics: \"$keyword\"")
                indicators.add("Attacker creates false urgency to provoke impulsive credential entry.")
                score += 20
            }
        }

        // Subdomain stuffing check
        if (isUrl && lower.count { it == '.' } > 3) {
            tactics.add("Subdomain Masking / Stuffing")
            indicators.add("Multiple nested subdomains often hide the true destination server.")
            score += 15
        }

        score = score.coerceIn(0, 100)

        val severity = when {
            score >= 70 -> ThreatSeverity.CRITICAL
            score >= 50 -> ThreatSeverity.HIGH
            score >= 25 -> ThreatSeverity.MEDIUM
            score >= 15 -> ThreatSeverity.LOW
            else -> ThreatSeverity.SAFE
        }

        val isPhishing = score >= 35

        val recommendation = when {
            score >= 70 -> "DO NOT OPEN OR INTERACT. This is an active malicious phishing attack designed for credential harvesting or session hijacking. LEADS has marked this source as blocked."
            score >= 40 -> "High likelihood of social engineering or deceptive phishing. Avoid clicking links or submitting any personal credentials."
            score >= 20 -> "Minor risk indicators detected. Exercise caution and verify sender authenticity directly through official channels."
            else -> "No recognizable malicious signatures or deceptive heuristics detected. The link/content appears standard."
        }

        return PhishingAnalysisVerdict(
            inputQuery = input,
            isPhishing = isPhishing,
            riskSeverity = severity,
            riskScore = score,
            detectedTactics = if (tactics.isEmpty()) listOf("No malicious patterns found") else tactics,
            deceptiveIndicators = if (indicators.isEmpty()) listOf("Legitimate syntax structure observed") else indicators,
            aiRecommendation = recommendation,
            cleanUrlPreview = if (isUrl) input.substringBefore("?").take(45) else null
        )
    }
}
