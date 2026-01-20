import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';

class GPTService {
  static Future<Map<String, dynamic>> sendToGPT(String englishText) async {
    return await analyzeTransaction(englishText);
  }

  static Future<Map<String, dynamic>> analyzeTransaction(String text) async {
    final url = Uri.parse("https://api.openai.com/v1/chat/completions");

    final prompt =
        """
You are an intent and amount extraction system for a digital khata book
used by idol makers in Kolkata.
You are working for an idol-maker finance app.

NORMALIZATION RULES (MANDATORY):
- Treat the following words as the SAME worker_type:

  painting:
    paint, painting, color, colour, rang, rang kora, paint work, colouring

  clay:
    clay, mati, modeling, murti goran, clay work

  structure:
    bamboo, kathamo, structure, frame, wood work

- If any synonym appears in the input text, you MUST map it to the corresponding worker_type.
- Do NOT output "other" if a synonym matches.

ALLOWED worker_type values:
- painting
- clay
- structure
- other (ONLY if no synonym matches)

If worker_type is inferred using these rules, confidence must be >= 0.8.

PERSON INCOME RULE (MANDATORY):
- If money is received from a PERSON NAME and no samiti/order keywords are present,
  classify as:
  {
    "intent": "income",
    "amount": number,
    "category": "other"
  }
- Person names are NOT samiti unless words like "samiti", "committee", "puja", or "association" appear.

Supported intents:
- income: general income received
- expense: general expense paid
- samiti_fund: money received from a samiti (organization/committee)
- worker_payment: payment made to a worker
- order_payment: payment received for an order
- unknown: cannot determine intent

For worker_payment intent, you MUST return:
{
  "intent": "worker_payment",
  "amount": number,
  "worker_name": string | null,
  "worker_type": one of ["clay", "painting", "decoration", "transport", "other"],
  "idol_type": one of ["durga", "ganesh", "saraswati", "lakshmi", "unknown"],
  "confidence": number between 0 and 1
}

For all other intents, return:
{
  "intent": "income" | "expense" | "samiti_fund" | "order_payment" | "unknown",
  "amount": number (0 if none),
  "category": "samiti" | "worker" | "material" | "transport" | "other" | null
}

IMPORTANT RULES:
- If a field is not clearly mentioned, return null instead of guessing
- For worker_payment, extract worker_name, worker_type, and idol_type only if explicitly mentioned
- worker_type must be one of: "clay", "painting", "decoration", "transport", "other"
- idol_type must be one of: "durga", "ganesh", "saraswati", "lakshmi", "unknown"
- confidence should reflect how certain you are (0.0 to 1.0)

Examples:

Input: "Paid 100 rupees to Ramesh in clay"
Output:
{
  "intent": "worker_payment",
  "amount": 100,
  "worker_name": "Ramesh",
  "worker_type": "clay",
  "idol_type": "unknown",
  "confidence": 0.92
}

Input: "Received 5000 from Behala Samity"
Output:
{
  "intent": "samiti_fund",
  "amount": 5000,
  "category": "samiti"
}

Input: "Sold 2 idols for 10000"
Output:
{
  "intent": "order_payment",
  "amount": 10000,
  "category": "other"
}

Input: "Bought paint for 2000"
Output:
{
  "intent": "expense",
  "amount": 2000,
  "category": "material"
}

Input: "Received 2000 from Rahul"
Output:
{
  "intent": "income",
  "amount": 2000,
  "category": "other"
}

Now extract from this input:
$text
""";

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${ApiKeys.openAI}",
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": [
          {"role": "user", "content": prompt},
        ],
        "temperature": 0,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("GPT error: ${response.body}");
    }

    final data = jsonDecode(response.body);
    final content = data["choices"][0]["message"]["content"];

    return jsonDecode(content);
  }
}
