/**
 * Meta-cognition LLM
 * Observes thinking process and decides tendency adjustments
 */

import { generateObject } from "ai";
import { z } from "zod";
import type { LanguageModel } from "ai";
import type { TendencyState } from "./tendency.ts";

export interface MetaCognitionInput {
  recentThoughts: string[];
  currentTendency: TendencyState;
  externalPressure?: string; // e.g., "be more conservative"
  originalPrompt: string;
}

export interface TendencyAdjustment {
  shouldAdjust: boolean;
  dimension?: "informationProcessing" | "decisionMaking" | "structurePreference" | "energyFocus";
  newDescription?: string;
  reason?: string;
}

const adjustmentSchema = z.object({
  shouldAdjust: z.boolean().describe("Whether to adjust any tendency"),
  dimension: z.enum(["informationProcessing", "decisionMaking", "structurePreference", "energyFocus"])
    .optional()
    .describe("Which dimension to adjust"),
  newDescription: z.string()
    .optional()
    .describe("New description for the tendency (subtle shift, not extreme)"),
  reason: z.string()
    .optional()
    .describe("Brief reason for the adjustment"),
});

/**
 * Meta-cognition: observe thinking and decide on tendency adjustments
 */
export async function metaCognition(
  model: LanguageModel,
  input: MetaCognitionInput
): Promise<TendencyAdjustment> {
  const systemPrompt = `You are a meta-cognitive observer. Your role is to observe a thinking process and decide if the thinking tendencies should be subtly adjusted.

You are NOT the thinker. You observe and guide.

Current tendencies:
- Information processing: ${input.currentTendency.descriptions.informationProcessing}
- Decision making: ${input.currentTendency.descriptions.decisionMaking}
- Structure preference: ${input.currentTendency.descriptions.structurePreference}
- Energy focus: ${input.currentTendency.descriptions.energyFocus}

${input.externalPressure ? `External pressure/guidance: "${input.externalPressure}"` : "No external pressure."}

Guidelines:
- Only suggest adjustment if truly needed
- Adjustments should be subtle shifts, not dramatic changes
- Consider if external pressure should influence the adjustment
- Don't adjust just to be different; adjust to improve thinking quality`;

  const userPrompt = `Original question: ${input.originalPrompt}

Recent thinking:
${input.recentThoughts.map((t, i) => `[${i + 1}] ${t}`).join("\n\n")}

Should any tendency be adjusted for the next segment of thinking?`;

  const { object } = await generateObject({
    model,
    schema: adjustmentSchema,
    system: systemPrompt,
    prompt: userPrompt,
  });

  return object;
}

/**
 * Apply adjustment to tendency state
 */
export function applyAdjustment(
  current: TendencyState,
  adjustment: TendencyAdjustment
): TendencyState {
  if (!adjustment.shouldAdjust || !adjustment.dimension || !adjustment.newDescription) {
    return current;
  }

  return {
    descriptions: {
      ...current.descriptions,
      [adjustment.dimension]: adjustment.newDescription,
    },
  };
}
