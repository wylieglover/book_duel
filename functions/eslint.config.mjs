// functions/eslint.config.mjs

import js from "@eslint/js";
import { fileURLToPath } from "url";
import { dirname, resolve } from "path";
import tsParser from "@typescript-eslint/parser";
import tsPlugin from "@typescript-eslint/eslint-plugin";
// @ts-expect-error no types for eslint-plugin-import
import importPlugin from "eslint-plugin-import";

const __filename = fileURLToPath(import.meta.url);
const __dirname  = dirname(__filename);

// Extract the TS-ESLint configs we want
const { recommended: tsRecommended, "recommended-requiring-type-checking": tsTypeChecked } =
  tsPlugin.configs;

export default [
  // 1) Completely ignore any generated code
  {
    ignores: ["lib/**", "node_modules/**"]
  },

  // 2) Base JS rules
  js.configs.recommended,

  // 3) TypeScript overrides for all .ts files
  {
    files: ["**/*.ts"],
    languageOptions: {
      parser: tsParser,
      parserOptions: {
        ecmaVersion: 2022,
        sourceType: "module",
        project: resolve(__dirname, "tsconfig.json"),
        tsconfigRootDir: __dirname,
      },
      globals: {
        fetch: "readonly",
        Buffer: "readonly",
        URL: "readonly",
      },
    },
    plugins: {
      "@typescript-eslint": tsPlugin,
      import: importPlugin,
    },
    rules: {
      // include TS-ESLint recommended and type-checked rules
      ...tsRecommended.rules,
      ...tsTypeChecked.rules,

      // your custom tweaks
      "quotes": ["error", "double"],
      "indent": ["error", 2],
      "max-len": ["error", { code: 130 }],
      "import/no-unresolved": "off",
    },
  },
];
