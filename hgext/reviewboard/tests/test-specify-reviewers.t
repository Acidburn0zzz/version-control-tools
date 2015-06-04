#require docker

  $ . $TESTDIR/hgext/reviewboard/tests/helpers.sh
  $ commonenv

Enable obsolescence so we can test code paths which use it.

  $ echo "[experimental]" >> client/.hg/hgrc
  $ echo "evolution = all" >> client/.hg/hgrc

Create an initial commit.

  $ cd client
  $ echo foo > foo
  $ hg commit -A -m 'root commit'
  adding foo
  $ hg phase --public -r .

Add some potential reviewers.

  $ adminbugzilla create-user romulus@example.com password 'Romulus :romulus'
  created user 6
  $ adminbugzilla create-user remus@example.com password 'Remus :remus'
  created user 7

We create a user with a name which contains another user name as a prefix to
exercise the code path where multiple users are returned for a query.

  $ adminbugzilla create-user remus2@example.com password 'Remus2 :remus2'
  created user 8

Try a bunch of different ways of specifying a reviewer

  $ bugzilla create-bug TestProduct TestComponent 'First Bug'
  $ echo initial > foo
  $ hg commit -m 'Bug 1 - some stuff; r?romulus'
  $ echo blah >> foo
  $ hg commit -m 'Bug 1 - More stuff; r?romulus, r?remus'
  $ echo blah >> foo
  $ hg commit -m 'Bug 1 - More stuff; r?romulus,r?remus'
  $ echo blah >> foo
  $ hg commit -m 'Bug 1 - More stuff; r?romulus, remus'
  $ echo blah >> foo
  $ hg commit -m 'Bug 1 - More stuff; r?romulus,remus'
  $ echo blah >> foo
  $ hg commit -m 'Bug 1 - More stuff; (r?romulus)'
  $ echo blah >> foo
  $ hg commit -m 'Bug 1 - More stuff; (r?romulus,remus)'
  $ echo blah >> foo
  $ hg commit -m 'Bug 1 - More stuff; [r?romulus]'
  $ echo blah >> foo
  $ hg commit -m 'Bug 1 - More stuff; [r?remus, r?romulus]'
  $ echo blah >> foo
  $ hg commit -m 'Bug 1 - More stuff; r?romulus, a=test-only'
  $ hg push
  pushing to ssh://*:$HGPORT6/test-repo (glob)
  (adding commit id to 10 changesets)
  searching for changes
  remote: adding changesets
  remote: adding manifests
  remote: adding file changes
  remote: added 11 changesets with 11 changes to 1 files
  remote: Trying to insert into pushlog.
  remote: Inserted into the pushlog db successfully.
  submitting 10 changesets for review
  
  changeset:  11:fcf566e4c32a
  summary:    Bug 1 - some stuff; r?romulus
  review:     http://*:$HGPORT1/r/2 (draft) (glob)
  
  changeset:  12:c62a829e2f0a
  summary:    Bug 1 - More stuff; r?romulus, r?remus
  review:     http://*:$HGPORT1/r/3 (draft) (glob)
  
  changeset:  13:955576a13e6c
  summary:    Bug 1 - More stuff; r?romulus,r?remus
  review:     http://*:$HGPORT1/r/4 (draft) (glob)
  
  changeset:  14:696e908c00aa
  summary:    Bug 1 - More stuff; r?romulus, remus
  review:     http://*:$HGPORT1/r/5 (draft) (glob)
  
  changeset:  15:92e037a5e92f
  summary:    Bug 1 - More stuff; r?romulus,remus
  review:     http://*:$HGPORT1/r/6 (draft) (glob)
  
  changeset:  16:a7c3071c6b54
  summary:    Bug 1 - More stuff; (r?romulus)
  review:     http://*:$HGPORT1/r/7 (draft) (glob)
  
  changeset:  17:7b03b2560ab0
  summary:    Bug 1 - More stuff; (r?romulus,remus)
  review:     http://*:$HGPORT1/r/8 (draft) (glob)
  
  changeset:  18:42c4d67a510e
  summary:    Bug 1 - More stuff; [r?romulus]
  review:     http://*:$HGPORT1/r/9 (draft) (glob)
  
  changeset:  19:2bc874a070ce
  summary:    Bug 1 - More stuff; [r?remus, r?romulus]
  review:     http://*:$HGPORT1/r/10 (draft) (glob)
  
  changeset:  20:9138f440ecac
  summary:    Bug 1 - More stuff; r?romulus, a=test-only
  review:     http://*:$HGPORT1/r/11 (draft) (glob)
  
  review id:  bz://1/mynick
  review url: http://*:$HGPORT1/r/1 (draft) (glob)
  (visit review url to publish this review request so others can see it)

  $ rbmanage list-reviewers 2 --draft
  romulus

  $ rbmanage list-reviewers 3 --draft
  remus, romulus

  $ rbmanage list-reviewers 4 --draft
  remus, romulus

  $ rbmanage list-reviewers 5 --draft
  remus, romulus

  $ rbmanage list-reviewers 6 --draft
  remus, romulus

  $ rbmanage list-reviewers 7 --draft
  romulus

  $ rbmanage list-reviewers 8 --draft
  remus, romulus

  $ rbmanage list-reviewers 9 --draft
  romulus

  $ rbmanage list-reviewers 10 --draft
  remus, romulus

  $ rbmanage list-reviewers 11 --draft
  romulus

Amending a commit should also work. This exercises the update_review_request
code path.

  $ echo blah >> foo
  $ hg commit --amend -m 'Bug 1 - Even more stuff; r?romulus, r?remus'
  $ hg push
  pushing to ssh://*:$HGPORT6/test-repo (glob)
  searching for changes
  remote: adding changesets
  remote: adding manifests
  remote: adding file changes
  remote: added 1 changesets with 1 changes to 1 files (+1 heads)
  remote: Trying to insert into pushlog.
  remote: Inserted into the pushlog db successfully.
  submitting 10 changesets for review
  
  changeset:  11:fcf566e4c32a
  summary:    Bug 1 - some stuff; r?romulus
  review:     http://*:$HGPORT1/r/2 (draft) (glob)
  
  changeset:  12:c62a829e2f0a
  summary:    Bug 1 - More stuff; r?romulus, r?remus
  review:     http://*:$HGPORT1/r/3 (draft) (glob)
  
  changeset:  13:955576a13e6c
  summary:    Bug 1 - More stuff; r?romulus,r?remus
  review:     http://*:$HGPORT1/r/4 (draft) (glob)
  
  changeset:  14:696e908c00aa
  summary:    Bug 1 - More stuff; r?romulus, remus
  review:     http://*:$HGPORT1/r/5 (draft) (glob)
  
  changeset:  15:92e037a5e92f
  summary:    Bug 1 - More stuff; r?romulus,remus
  review:     http://*:$HGPORT1/r/6 (draft) (glob)
  
  changeset:  16:a7c3071c6b54
  summary:    Bug 1 - More stuff; (r?romulus)
  review:     http://*:$HGPORT1/r/7 (draft) (glob)
  
  changeset:  17:7b03b2560ab0
  summary:    Bug 1 - More stuff; (r?romulus,remus)
  review:     http://*:$HGPORT1/r/8 (draft) (glob)
  
  changeset:  18:42c4d67a510e
  summary:    Bug 1 - More stuff; [r?romulus]
  review:     http://*:$HGPORT1/r/9 (draft) (glob)
  
  changeset:  19:2bc874a070ce
  summary:    Bug 1 - More stuff; [r?remus, r?romulus]
  review:     http://*:$HGPORT1/r/10 (draft) (glob)
  
  changeset:  22:f70fd1f0a35e
  summary:    Bug 1 - Even more stuff; r?romulus, r?remus
  review:     http://*:$HGPORT1/r/11 (draft) (glob)
  
  review id:  bz://1/mynick
  review url: http://*:$HGPORT1/r/1 (draft) (glob)
  (visit review url to publish this review request so others can see it)
 
  $ rbmanage list-reviewers 11 --draft
  remus, romulus

We should not overwrite manually added reviewers when the revision is pushed
again.

  $ rbmanage add-reviewer 11 --user admin+1
  3 people listed on review request
  $ rbmanage list-reviewers 11 --draft
  admin+1, remus, romulus
  $ hg push
  pushing to ssh://*:$HGPORT6/test-repo (glob)
  searching for changes
  no changes found
  submitting 10 changesets for review
  
  changeset:  11:fcf566e4c32a
  summary:    Bug 1 - some stuff; r?romulus
  review:     http://*:$HGPORT1/r/2 (draft) (glob)
  
  changeset:  12:c62a829e2f0a
  summary:    Bug 1 - More stuff; r?romulus, r?remus
  review:     http://*:$HGPORT1/r/3 (draft) (glob)
  
  changeset:  13:955576a13e6c
  summary:    Bug 1 - More stuff; r?romulus,r?remus
  review:     http://*:$HGPORT1/r/4 (draft) (glob)
  
  changeset:  14:696e908c00aa
  summary:    Bug 1 - More stuff; r?romulus, remus
  review:     http://*:$HGPORT1/r/5 (draft) (glob)
  
  changeset:  15:92e037a5e92f
  summary:    Bug 1 - More stuff; r?romulus,remus
  review:     http://*:$HGPORT1/r/6 (draft) (glob)
  
  changeset:  16:a7c3071c6b54
  summary:    Bug 1 - More stuff; (r?romulus)
  review:     http://*:$HGPORT1/r/7 (draft) (glob)
  
  changeset:  17:7b03b2560ab0
  summary:    Bug 1 - More stuff; (r?romulus,remus)
  review:     http://*:$HGPORT1/r/8 (draft) (glob)
  
  changeset:  18:42c4d67a510e
  summary:    Bug 1 - More stuff; [r?romulus]
  review:     http://*:$HGPORT1/r/9 (draft) (glob)
  
  changeset:  19:2bc874a070ce
  summary:    Bug 1 - More stuff; [r?remus, r?romulus]
  review:     http://*:$HGPORT1/r/10 (draft) (glob)
  
  changeset:  22:f70fd1f0a35e
  summary:    Bug 1 - Even more stuff; r?romulus, r?remus
  review:     http://*:$HGPORT1/r/11 (draft) (glob)
  
  review id:  bz://1/mynick
  review url: http://*:$HGPORT1/r/1 (draft) (glob)
  (visit review url to publish this review request so others can see it)
  [1]
  $ rbmanage list-reviewers 11 --draft
  admin+1, remus, romulus

We should not overwrite manually added reviewers if the revision is amended 
and pushed with no reviewers specified.

  $ rbmanage list-reviewers 11 --draft
  admin+1, remus, romulus
  $ echo blah >> foo
  $ hg commit --amend -m 'Bug 1 - Amended stuff'
  $ hg push
  pushing to ssh://*:$HGPORT6/test-repo (glob)
  searching for changes
  remote: adding changesets
  remote: adding manifests
  remote: adding file changes
  remote: added 1 changesets with 1 changes to 1 files (+1 heads)
  remote: Trying to insert into pushlog.
  remote: Inserted into the pushlog db successfully.
  submitting 10 changesets for review
  
  changeset:  11:fcf566e4c32a
  summary:    Bug 1 - some stuff; r?romulus
  review:     http://*:$HGPORT1/r/2 (draft) (glob)
  
  changeset:  12:c62a829e2f0a
  summary:    Bug 1 - More stuff; r?romulus, r?remus
  review:     http://*:$HGPORT1/r/3 (draft) (glob)
  
  changeset:  13:955576a13e6c
  summary:    Bug 1 - More stuff; r?romulus,r?remus
  review:     http://*:$HGPORT1/r/4 (draft) (glob)
  
  changeset:  14:696e908c00aa
  summary:    Bug 1 - More stuff; r?romulus, remus
  review:     http://*:$HGPORT1/r/5 (draft) (glob)
  
  changeset:  15:92e037a5e92f
  summary:    Bug 1 - More stuff; r?romulus,remus
  review:     http://*:$HGPORT1/r/6 (draft) (glob)
  
  changeset:  16:a7c3071c6b54
  summary:    Bug 1 - More stuff; (r?romulus)
  review:     http://*:$HGPORT1/r/7 (draft) (glob)
  
  changeset:  17:7b03b2560ab0
  summary:    Bug 1 - More stuff; (r?romulus,remus)
  review:     http://*:$HGPORT1/r/8 (draft) (glob)
  
  changeset:  18:42c4d67a510e
  summary:    Bug 1 - More stuff; [r?romulus]
  review:     http://*:$HGPORT1/r/9 (draft) (glob)
  
  changeset:  19:2bc874a070ce
  summary:    Bug 1 - More stuff; [r?remus, r?romulus]
  review:     http://*:$HGPORT1/r/10 (draft) (glob)
  
  changeset:  24:4a950181ffd8
  summary:    Bug 1 - Amended stuff
  review:     http://*:$HGPORT1/r/11 (draft) (glob)
  
  review id:  bz://1/mynick
  review url: http://*:$HGPORT1/r/1 (draft) (glob)
  (visit review url to publish this review request so others can see it)

  $ rbmanage list-reviewers 11 --draft
  admin+1, remus, romulus

Amending a commit with reviewers specified will reset the reviewers back to
those specified in the commit summary.

  $ echo blah >> foo
  $ hg commit --amend -m 'Bug 1 - Amended stuff; r?romulus, r?remus'
  $ hg push
  pushing to ssh://*:$HGPORT6/test-repo (glob)
  searching for changes
  remote: adding changesets
  remote: adding manifests
  remote: adding file changes
  remote: added 1 changesets with 1 changes to 1 files (+1 heads)
  remote: Trying to insert into pushlog.
  remote: Inserted into the pushlog db successfully.
  submitting 10 changesets for review
  
  changeset:  11:fcf566e4c32a
  summary:    Bug 1 - some stuff; r?romulus
  review:     http://*:$HGPORT1/r/2 (draft) (glob)
  
  changeset:  12:c62a829e2f0a
  summary:    Bug 1 - More stuff; r?romulus, r?remus
  review:     http://*:$HGPORT1/r/3 (draft) (glob)
  
  changeset:  13:955576a13e6c
  summary:    Bug 1 - More stuff; r?romulus,r?remus
  review:     http://*:$HGPORT1/r/4 (draft) (glob)
  
  changeset:  14:696e908c00aa
  summary:    Bug 1 - More stuff; r?romulus, remus
  review:     http://*:$HGPORT1/r/5 (draft) (glob)
  
  changeset:  15:92e037a5e92f
  summary:    Bug 1 - More stuff; r?romulus,remus
  review:     http://*:$HGPORT1/r/6 (draft) (glob)
  
  changeset:  16:a7c3071c6b54
  summary:    Bug 1 - More stuff; (r?romulus)
  review:     http://*:$HGPORT1/r/7 (draft) (glob)
  
  changeset:  17:7b03b2560ab0
  summary:    Bug 1 - More stuff; (r?romulus,remus)
  review:     http://*:$HGPORT1/r/8 (draft) (glob)
  
  changeset:  18:42c4d67a510e
  summary:    Bug 1 - More stuff; [r?romulus]
  review:     http://*:$HGPORT1/r/9 (draft) (glob)
  
  changeset:  19:2bc874a070ce
  summary:    Bug 1 - More stuff; [r?remus, r?romulus]
  review:     http://*:$HGPORT1/r/10 (draft) (glob)
  
  changeset:  26:3ec3b449ccca
  summary:    Bug 1 - Amended stuff; r?romulus, r?remus
  review:     http://*:$HGPORT1/r/11 (draft) (glob)
  
  review id:  bz://1/mynick
  review url: http://*:$HGPORT1/r/1 (draft) (glob)
  (visit review url to publish this review request so others can see it)
  $ rbmanage list-reviewers 11 --draft
  remus, romulus

Unrecognized reviewers should be ignored

  $ hg phase --public -r .
  $ bugzilla create-bug TestProduct TestComponent 'Second Bug'
  $ echo blah >> foo
  $ hg commit -m 'Bug 2 - different stuff; r?cthulhu'
  $ hg push --reviewid 2
  pushing to ssh://*:$HGPORT6/test-repo (glob)
  searching for changes
  remote: adding changesets
  remote: adding manifests
  remote: adding file changes
  remote: added 1 changesets with 1 changes to 1 files
  remote: Trying to insert into pushlog.
  remote: Inserted into the pushlog db successfully.
  submitting 1 changesets for review
  
  changeset:  27:d9a3b1783a10
  summary:    Bug 2 - different stuff; r?cthulhu
  review:     http://*:$HGPORT1/r/13 (draft) (glob)
  
  review id:  bz://2/mynick
  review url: http://*:$HGPORT1/r/12 (draft) (glob)
  (visit review url to publish this review request so others can see it)
  $ rbmanage list-reviewers 12 --draft
  
 
Using r= for a patch under review instead of r? should result in a warning
from the client.

  $ echo blah >> foo
  $ hg commit -m 'Bug 2 - different stuff; r=romulus'
  $ hg push
  pushing to ssh://*:$HGPORT6/test-repo (glob)
  searching for changes
  remote: adding changesets
  remote: adding manifests
  remote: adding file changes
  remote: added 1 changesets with 1 changes to 1 files
  remote: Trying to insert into pushlog.
  remote: Inserted into the pushlog db successfully.
  submitting 2 changesets for review
  
  changeset:  27:d9a3b1783a10
  summary:    Bug 2 - different stuff; r?cthulhu
  review:     http://*:$HGPORT1/r/13 (draft) (glob)
  
  changeset:  28:c486e8175a60
  summary:    Bug 2 - different stuff; r=romulus
  (It appears you are using r= to specify reviewers for a patch under review. Please use r? to avoid ambiguity as to whether or not review has been granted.)
  review:     http://*:$HGPORT1/r/14 (draft) (glob)
  
  review id:  bz://2/mynick
  review url: http://*:$HGPORT1/r/12 (draft) (glob)
  (visit review url to publish this review request so others can see it)
 
 
Cleanup

  $ mozreview stop
  stopped 8 containers