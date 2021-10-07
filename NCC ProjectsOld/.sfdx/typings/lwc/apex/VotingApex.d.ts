declare module "@salesforce/apex/VotingApex.Voteslike" {
  export default function Voteslike(param: {getId: any}): Promise<any>;
}
declare module "@salesforce/apex/VotingApex.VotesdisLikes" {
  export default function VotesdisLikes(param: {getId: any}): Promise<any>;
}
declare module "@salesforce/apex/VotingApex.insertVoteup" {
  export default function insertVoteup(param: {LikeView: any, disLikeView: any, values: any, getId: any}): Promise<any>;
}
declare module "@salesforce/apex/VotingApex.insertvotedown" {
  export default function insertvotedown(param: {disLikeView: any, likeview: any, values: any, getId: any}): Promise<any>;
}
