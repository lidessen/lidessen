/**
 * Tendency dimensions inspired by MBTI
 * These are not fixed values, but descriptions that can be adjusted
 */

export interface TendencyState {
  // Current tendency descriptions (not numbers)
  // These get adjusted by meta-cognition
  descriptions: {
    informationProcessing: string; // S/N dimension
    decisionMaking: string;        // T/F dimension
    structurePreference: string;   // J/P dimension
    energyFocus: string;           // E/I dimension
  };
}

export const defaultTendency: TendencyState = {
  descriptions: {
    informationProcessing: "balanced between concrete details and abstract patterns",
    decisionMaking: "balanced between logical analysis and value-based judgment",
    structurePreference: "balanced between reaching conclusions and staying open",
    energyFocus: "balanced between external feedback and internal reflection",
  },
};

/**
 * Build a tendency prompt from current state
 */
export function buildTendencyPrompt(state: TendencyState): string {
  return `Your current thinking tendencies:
- Information processing: ${state.descriptions.informationProcessing}
- Decision making: ${state.descriptions.decisionMaking}
- Structure preference: ${state.descriptions.structurePreference}
- Energy focus: ${state.descriptions.energyFocus}

These tendencies subtly influence how you think, not what you think.`;
}
