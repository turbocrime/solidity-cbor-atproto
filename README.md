# turbocrime/solidity-cbor-atproto

**This is a library for parsing and verifying record inclusion in atproto repositories.**

Developed by reference to the [atproto repository data model](https://atproto.com/specs/data-model).

## Usage

This library is designed for use with off-chain software which selects appropriate records and formats contract calldata.

Your contract should be capable of verifying the signature on the commit.

### off-chain

You identify a new record of interest.

1. know the actor `did`, namespaced `collection`, and `rkey` identifying the record of interest
1. query the appropriate PDS with `com.atproto.sync.getRecord` to obtain the proof data
2. parse the response carfile and separate:
   - the tree node CBORs
   - the record CBOR
   - the unsigned commit CBOR
   - the commit signature `r` and `s` components

Call your contract.

### on-chain

Your established contract is called.

4. knowing a trusted signer, validate the commit signature.
5. parse the commit with `readCommit`. a root CID and new revision return.
6. knowing a previous revision, confirm the new revision is appropriate.
7. with the record key and the root CID, parse the tree with `verifyInclusion`. an included CID returns.
8. confirm the record content is identified by the included CID.

Record inclusion is proven. You may proceed to parse and act on the authenticated record.

### Example

Contract use of this library might look like this:

```solidity
function exampleUse(
    bytes memory commitCbor,
    bytes memory recordCbor,
    bytes[] memory mstCbors,
    bytes32 sig_r,
    bytes32 sig_s,
    string memory recordKey
) internal view {
    require(mySigVerification(commitCbor, sig_r, sig_s), "Commit signature should be valid");
    Commit memory commit = commitCbor.readCommit();

    require(myRevisionComparison(myLastRev, commit.rev), "Revision should be newer");
    myLastRev = commit.rev;

    Tree memory mst = mstCbors.readTree();
    CidSha256 includedCid = mst.verifyInclusion(commit.data, recordKey);
    require(includedCid.isFor(recordCbor), "Key should identify the record");

    myContractLogic(recordCbor);
}
```

## Record parsing

Record parsing utilities are provided for these bluesky lexicons:

- `app.bsky.feed.post`
- `app.bsky.feed.like`
- `app.bsky.feed.repost`

Otherwise, you are responsible for implementing your own record parsing.
