package dev.tuanle.chatgpt.service;

import org.springframework.stereotype.Service;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class ChatService {

    public String formatResponse(String response) {
        // Step 1: Convert markdown-style lists to <ul>
        response = response.replaceAll("(?m)^[-*]\\s+(.*)", "<ul><li>$1</li></ul>");

        // Step 2: Convert markdown-style headings (## Title → <h2>Title</h2>)
        response = response.replaceAll("(?m)^##\\s+(.*)", "<h2>$1</h2>");
        response = response.replaceAll("(?m)^#\\s+(.*)", "<h1>$1</h1>");

        // Step 3: Convert code blocks (```java ... ```) to <pre><code>
        Pattern pattern = Pattern.compile("```(\\w+)?\\n([\\s\\S]*?)```");
        Matcher matcher = pattern.matcher(response);
        StringBuffer formattedResponse = new StringBuffer();
        while (matcher.find()) {
            String language = matcher.group(1) != null ? matcher.group(1) : "plaintext"; // Default to plaintext
            String codeSnippet = matcher.group(2);

            String replacement = "<pre><code class=\"language-" + language + "\">"
                    + escapeHtml(codeSnippet) + "</code></pre>";
            matcher.appendReplacement(formattedResponse, replacement);
        }
        matcher.appendTail(formattedResponse);
        response = formattedResponse.toString();

        // Step 4: Preserve new lines as <br>
        return response.replace("\n", "<br>");
    }

    private String escapeHtml(String input) {
        return input.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    }
}
