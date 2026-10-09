import vue from 'eslint-plugin-vue';
import tseslint from 'typescript-eslint';
import vueParser from 'vue-eslint-parser';

export default [
 {ignores:['dist/**','node_modules/**']},
 ...vue.configs['flat/essential'],
 ...tseslint.configs.strict,
 {files:['src/mobile/**/*.vue'],languageOptions:{parser:vueParser,parserOptions:{parser:tseslint.parser,ecmaVersion:'latest',sourceType:'module'}}},
 {files:['src/mobile/**/*.{ts,vue}'],rules:{'@typescript-eslint/no-explicit-any':'error'}}
];
