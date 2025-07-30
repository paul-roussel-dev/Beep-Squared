package com.example.beep_squared

import kotlin.random.Random

/**
 * Mathematical challenge generator for alarm unlock system
 * 
 * Generates mathematical problems (addition, subtraction, multiplication)
 * with appropriate difficulty levels for alarm dismissal.
 */
object MathChallengeGenerator {
    
    /**
     * Data class representing a mathematical challenge
     */
    data class MathChallenge(
        val question: String,
        val answer: Int,
        val operation: String
    )
    
    /**
     * Generate a mathematical challenge based on the unlock method
     */
    fun generateChallenge(unlockMethod: String): MathChallenge {
        return when (unlockMethod) {
            "addition" -> generateAdditionChallenge()
            "subtraction" -> generateSubtractionChallenge()
            "multiplication" -> generateMultiplicationChallenge()
            else -> generateAdditionChallenge() // Default fallback
        }
    }
    
    /**
     * Generate an addition challenge (1-99 + 1-99)
     */
    private fun generateAdditionChallenge(): MathChallenge {
        val a = Random.nextInt(1, 100)
        val b = Random.nextInt(1, 100)
        val answer = a + b
        
        return MathChallenge(
            question = "$a + $b = ?",
            answer = answer,
            operation = "addition"
        )
    }
    
    /**
     * Generate a subtraction challenge (10-99 - 1-30)
     * Ensures positive results
     */
    private fun generateSubtractionChallenge(): MathChallenge {
        val a = Random.nextInt(10, 100)
        val b = Random.nextInt(1, 31)
        val answer = a - b
        
        return MathChallenge(
            question = "$a - $b = ?",
            answer = answer,
            operation = "subtraction"
        )
    }
    
    /**
     * Generate a multiplication challenge (1-12 × 1-12)
     * Keeps numbers manageable
     */
    private fun generateMultiplicationChallenge(): MathChallenge {
        val a = Random.nextInt(1, 13)
        val b = Random.nextInt(1, 13)
        val answer = a * b
        
        return MathChallenge(
            question = "$a × $b = ?",
            answer = answer,
            operation = "multiplication"
        )
    }
}
