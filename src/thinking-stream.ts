/**
 * Thinking Stream - voice switching mechanism
 *
 * The core idea: during thinking, switch between different tendencies
 * not as separate speakers, but as shifting inclinations within one mind.
 */

import { streamText, type LanguageModel } from "ai";
import { type Voice, voices, getRandomVoice } from "./voices.ts";

export interface ThinkingStreamConfig {
  model: LanguageModel;
  switchStrategy: "random" | "turn-based" | "semantic";
  minTokensBeforeSwitch: number;
  switchProbability: number; // for random strategy
}

export interface ThinkingResult {
  thoughts: ThoughtSegment[];
  finalThought: string;
}

export interface ThoughtSegment {
  voiceId: string;
  content: string;
  tokenCount: number;
}

const defaultConfig: Partial<ThinkingStreamConfig> = {
  switchStrategy: "turn-based",
  minTokensBeforeSwitch: 50,
  switchProbability: 0.3,
};

/**
 * Create a thinking stream that switches between voices
 */
export async function createThinkingStream(
  prompt: string,
  config: ThinkingStreamConfig,
  onSegment?: (segment: ThoughtSegment) => void
): Promise<ThinkingResult> {
  const cfg = { ...defaultConfig, ...config };
  const thoughts: ThoughtSegment[] = [];
  let context = prompt;
  let currentVoice = getRandomVoice();
  let iterations = 0;
  const maxIterations = 6; // prevent infinite loops

  while (iterations < maxIterations) {
    iterations++;

    const systemPrompt = buildSystemPrompt(currentVoice, context, thoughts);

    const result = streamText({
      model: cfg.model,
      system: systemPrompt,
      prompt: buildContinuationPrompt(thoughts),
      maxTokens: 200, // short segments for frequent switching
      stopSequences: ["\n\n", "---"], // natural pause points
    });

    let segmentContent = "";

    for await (const chunk of result.textStream) {
      segmentContent += chunk;
      process.stdout.write(chunk); // real-time output
    }

    const segment: ThoughtSegment = {
      voiceId: currentVoice.id,
      content: segmentContent.trim(),
      tokenCount: estimateTokens(segmentContent),
    };

    thoughts.push(segment);
    onSegment?.(segment);

    // Check if thinking seems complete
    if (isThinkingComplete(segmentContent, thoughts)) {
      break;
    }

    // Switch voice based on strategy
    currentVoice = selectNextVoice(cfg, currentVoice, segmentContent);

    // Add visual separator for voice switch
    process.stdout.write("\n");
  }

  return {
    thoughts,
    finalThought: synthesizeThoughts(thoughts),
  };
}

function buildSystemPrompt(
  voice: Voice,
  originalPrompt: string,
  previousThoughts: ThoughtSegment[]
): string {
  const thoughtHistory =
    previousThoughts.length > 0
      ? `\n\nYour thinking so far:\n${previousThoughts.map((t) => t.content).join("\n")}`
      : "";

  return `You are thinking through a problem. ${voice.tendency}

Original question: ${originalPrompt}
${thoughtHistory}

Continue your thinking naturally. Don't summarize or conclude yet unless you've fully explored the problem.
Think out loud, showing your reasoning process.`;
}

function buildContinuationPrompt(thoughts: ThoughtSegment[]): string {
  if (thoughts.length === 0) {
    return "Let me think about this...";
  }
  return "Continuing my thinking...";
}

function selectNextVoice(
  config: ThinkingStreamConfig,
  currentVoice: Voice,
  _lastContent: string
): Voice {
  switch (config.switchStrategy) {
    case "random":
      if (Math.random() < config.switchProbability) {
        return getRandomVoice();
      }
      return currentVoice;

    case "turn-based":
      // Cycle through voices in order
      const currentIndex = voices.findIndex((v) => v.id === currentVoice.id);
      return voices[(currentIndex + 1) % voices.length]!;

    case "semantic":
      // TODO: analyze content and switch based on semantic triggers
      // For now, fall back to turn-based
      const idx = voices.findIndex((v) => v.id === currentVoice.id);
      return voices[(idx + 1) % voices.length]!;

    default:
      return currentVoice;
  }
}

function isThinkingComplete(
  lastContent: string,
  thoughts: ThoughtSegment[]
): boolean {
  // Check for conclusion indicators
  const conclusionMarkers = [
    "in conclusion",
    "to summarize",
    "my final thought",
    "therefore, i think",
    "so the answer is",
    "ultimately",
  ];

  const lowerContent = lastContent.toLowerCase();
  const hasConclusion = conclusionMarkers.some((marker) =>
    lowerContent.includes(marker)
  );

  // Also check if we've done enough iterations
  const enoughThoughts = thoughts.length >= 3;

  return hasConclusion && enoughThoughts;
}

function synthesizeThoughts(thoughts: ThoughtSegment[]): string {
  return thoughts.map((t) => t.content).join("\n\n");
}

function estimateTokens(text: string): number {
  // Rough estimate: ~4 characters per token
  return Math.ceil(text.length / 4);
}
