import { FilterContent } from './FilterContent.js';

export const ClassifyContent = async (userid: string, content: string) => {
  return FilterContent(userid, content);
};
