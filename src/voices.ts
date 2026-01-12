/**
 * Voice definitions - different thinking tendencies
 * These are subtle inclinations, not role-playing characters
 */

export interface Voice {
  id: string;
  name: string;
  tendency: string; // subtle prompt that influences thinking style
}

export const voices: Voice[] = [
  {
    id: "opportunity",
    name: "Opportunity-sensitive",
    tendency: `You tend to notice possibilities and opportunities first.
When thinking, you naturally ask "what could go right?" and "what potential does this have?"
You're drawn to exploring new angles and finding hidden value.`,
  },
  {
    id: "risk",
    name: "Risk-sensitive",
    tendency: `You tend to notice risks and edge cases first.
When thinking, you naturally ask "what could go wrong?" and "what are we missing?"
You're drawn to finding flaws and ensuring robustness.`,
  },
  {
    id: "practical",
    name: "Practical-focused",
    tendency: `You tend to focus on concrete implementation and feasibility.
When thinking, you naturally ask "how would this actually work?" and "what are the real constraints?"
You're drawn to actionable steps and realistic assessments.`,
  },
];

export function getVoice(id: string): Voice | undefined {
  return voices.find((v) => v.id === id);
}

export function getRandomVoice(): Voice {
  return voices[Math.floor(Math.random() * voices.length)]!;
}
