public with sharing class CommunitiesUserPermissionService {

  public static Map<String, Group> getUniversityGroups() {
    Map<String, Group> groupMap = new Map<String, Group>();
    for (Group g : [SELECT Id, developerName,name FROM Group WHERE type = 'Regular' AND developerName LIKE 'grp_%']) {
      groupMap.put(g.developerName, g);
    }
    return groupMap;
  }

  public class ContactShareMatch {
    public Id contactShareId {get; set;}
    public ContactShare rule {get; set;}
    public Boolean matchFound {get; set;}
  }

  public static Map<String, Map<Id, ContactShareMatch>> getExistingGroupSharingRules(Map<String, Group> groupMap) {
    Map<String, Map<Id, ContactShareMatch>> existingGroupSharingRulesMap = new Map<String, Map<Id, ContactShareMatch>>();
    for (ContactShare cs : [Select Id, contactId, userOrGroupId From ContactShare Where userOrGroupId In :groupMap.values()]) {
      if (existingGroupSharingRulesMap.get(cs.userOrGroupId) == null) {
        existingGroupSharingRulesMap.put(cs.userOrGroupId, new Map<Id, ContactShareMatch>());
      }
      ContactShareMatch csm = new ContactShareMatch();
      csm.contactShareId = cs.Id;
      csm.matchFound = false;
      csm.rule = cs;
      existingGroupSharingRulesMap.get(cs.userOrGroupId).put(cs.contactId, csm);
    }
    return existingGroupSharingRulesMap;
  }

  private static Map<String, Map<Id, GroupMemberMatch>> getExistingGroupMembers(List<User> userList) {
    Map<String, Map<Id, GroupMemberMatch>> groupMemberMap = new Map<String, Map<Id, GroupMemberMatch>>();
    for (GroupMember gm : [SELECT groupId, group.name, userOrGroupId FROM GroupMember WHERE userOrGroupId IN :userList OR group.developerName = 'All_Colleges_Universities']) {
      if (groupMemberMap.get(gm.groupId) == null) {
        groupMemberMap.put(gm.groupId, new Map<Id, GroupMemberMatch>());
      }
      GroupMemberMatch gmm = new GroupMemberMatch();
      gmm.groupMemberId = gm.Id;
      gmm.matchFound = false;
      groupMemberMap.get(gm.groupId).put(gm.userOrGroupId, gmm);
    }
    return groupMemberMap;
  }

  public class GroupMemberMatch {
    public Id groupMemberId {get; set;}
    public Boolean matchFound {get; set;}
  }

  public static void userPermissionsForCommunity() {
    Id collegeRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('College/University').getRecordTypeId();
//    list<User> userList = [SELECT Id, contact.accountId, contactId, contact.account.recordtypeId, contact.account.name, profile.Id FROM User WHERE contactId != null And profile.Name != 'DSF - Advisor (external)'];
//    The statement above used the profile 'DSF - Advisor (external)', which no longer indicates a partner user. 
    list<User> userList = [SELECT Id, Name, contact.accountId, contactId, contact.account.recordtypeId, contact.account.name, profile.Id 
                           FROM User WHERE contactId != null And profile.Name LIKE 'College - %'];
    Group allUniGroup = [SELECT ID FROM Group WHERE developerName = 'All_Colleges_Universities'];
    Map<String, Group> groupMap = getUniversityGroups();

    List<Group> toCreate = new List<Group>();
    for (User u : userList) {
      system.debug('User: '+u.Name+', Uni: '+u.Contact.Account.Name);
      system.debug('Account Record Type: ' + u.Contact.Account.recordtypeId);
      system.debug('Account ID: ' + u.contact.accountId);
      system.debug('Group Map lookup: ' + groupMap.get('grp_' + u.contact.accountId));
                   
      if (u.contact.account.recordtypeId == collegeRT && u.contact.accountId != null && groupMap.get('grp_' + u.contact.accountId) == null) {
        Group newGroup = new Group();
        newGroup.type = 'Regular';
        newGroup.name = u.contact.account.name;
        newGroup.doesSendEmailToMembers = false;
        newGroup.doesIncludeBosses = true;
        newGroup.developerName = 'grp_' + u.contact.accountId;
        groupMap.put(newGroup.developerName, newGroup);
        toCreate.add(newGroup);
        system.debug('MAKING GROUP ' + newGroup);
      }
    }
    insert toCreate;

    Map<String, Map<Id, GroupMemberMatch>> memberMap = getExistingGroupMembers(userList);
    List<GroupMember> toDelete = new List<GroupMember>();
    List<GroupMember> newMemberList = new List<GroupMember>();
    for (User u : userList) {
      if (u.contact.account.recordtypeId == collegeRT && u.contact.accountId != null && groupMap.get('grp_' + u.contact.accountId) != null) {

        GroupMemberMatch existingGroupMembershipFound = null;
        if (memberMap.get(groupMap.get('grp_' + u.contact.accountId).Id) != null) {
          existingGroupMembershipFound = memberMap.get(groupMap.get('grp_' + u.contact.accountId).Id).get(u.Id);
        }

        if (existingGroupMembershipFound == null) {
          GroupMember gm = new GroupMember();
          gm.userOrGroupID = u.Id;
          gm.groupId = groupMap.get('grp_' + u.contact.accountId).Id;
          newMemberList.add(gm);
          if (memberMap.get(groupMap.get('grp_' + u.contact.accountId).Id) == null) {
            memberMap.put(groupMap.get('grp_' + u.contact.accountId).Id, new Map<Id, GroupMemberMatch>());
          }
          GroupMemberMatch gmm = new GroupMemberMatch();
          gmm.matchFound = true;
          memberMap.get(groupMap.get('grp_' + u.contact.accountId).Id).put(u.Id, gmm);
        } else {
          memberMap.get(groupMap.get('grp_' + u.contact.accountId).Id).get(u.Id).matchFound = true;
        }

        //Add new group to "all colleges" group for reporting access
        if (allUniGroup != null && (memberMap.get(allUniGroup.Id) == null || memberMap.get(allUniGroup.Id).get(u.Id) == null)) {
          GroupMember gg = new GroupMember();
          gg.userOrGroupId = u.Id;
          gg.groupId = allUniGroup.Id;
          newMemberList.add(gg);
          if (memberMap.get(allUniGroup.Id) == null) {
            memberMap.put(allUniGroup.Id, new Map<Id, GroupMemberMatch>());
          }
          GroupMemberMatch gmm = new GroupMemberMatch();
          gmm.matchFound = true;
          memberMap.get(allUniGroup.Id).put(u.Id, gmm);
        } else {
          memberMap.get(allUniGroup.Id).get(u.Id).matchFound = true;
        }
      }
    }

    for (Map<Id, GroupMemberMatch> groupMembers : memberMap.values()) {
      for (GroupMemberMatch membership : groupMembers.values()) {
        if (!membership.matchFound && membership.groupMemberId != null) {
          GroupMember gm = new GroupMember();
          gm.Id = membership.groupMemberId;
          toDelete.add(gm);
        }
      }
    }
    delete toDelete;
    insert newMemberList;
  }
}