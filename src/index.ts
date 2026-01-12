/**
 * CLI entry point for voice switching experiment
 */

import { createDeepSeek } from "@ai-sdk/deepseek";
import { createThinkingStream } from "./thinking-stream.ts";

const deepseek = createDeepSeek({
  apiKey: process.env.DEEPSEEK_API_KEY ?? "",
});

async function main() {
  const prompt = process.argv[2] || "Should I learn Rust or Go as my next programming language?";

  console.log("=".repeat(60));
  console.log("Voice Switching Experiment");
  console.log("=".repeat(60));
  console.log(`\nPrompt: ${prompt}\n`);
  console.log("-".repeat(60));
  console.log("Thinking stream (voices will switch):\n");

  const result = await createThinkingStream(prompt, {
    model: deepseek("deepseek-chat"),
    switchStrategy: "turn-based",
    minTokensBeforeSwitch: 50,
    switchProbability: 0.3,
  });

  console.log("\n" + "=".repeat(60));
  console.log("Thinking complete.");
  console.log(`Total segments: ${result.thoughts.length}`);
  console.log(
    `Voices used: ${[...new Set(result.thoughts.map((t) => t.voiceId))].join(", ")}`
  );
}

main().catch(console.error);
