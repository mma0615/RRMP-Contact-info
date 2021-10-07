declare module "@salesforce/apex/KnowledgeApex.getKnowledgeArticles" {
  export default function getKnowledgeArticles(): Promise<any>;
}
declare module "@salesforce/apex/KnowledgeApex.getTrendingArticles" {
  export default function getTrendingArticles(): Promise<any>;
}
declare module "@salesforce/apex/KnowledgeApex.getRecentArticles" {
  export default function getRecentArticles(): Promise<any>;
}
declare module "@salesforce/apex/KnowledgeApex.getMostRatedArticles" {
  export default function getMostRatedArticles(): Promise<any>;
}
declare module "@salesforce/apex/KnowledgeApex.allArticles" {
  export default function allArticles(): Promise<any>;
}
declare module "@salesforce/apex/KnowledgeApex.getDescription" {
  export default function getDescription(param: {recordId: any}): Promise<any>;
}
