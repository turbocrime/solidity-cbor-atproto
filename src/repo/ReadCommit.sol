// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import "solidity-cbor/tags/ReadCidSha256.sol";
import "solidity-cbor/ReadCbor.sol";

using ReadCbor for bytes;
using ReadCidSha256 for bytes;

struct Commit {
    // omitted fields:
    // - uint8 verison;
    // - Null/CidSha256 prev;
    // - bytes sig;
    string did;
    CidSha256 data;
    string rev;
}

library ReadCommit {
    uint8 private constant COMMIT_VERSION = 3;
    uint8 private constant SIG_V = 1 + 27;

    function readCommit(bytes memory cbor) internal pure returns (Commit memory commit) {
        (uint32 i, uint mapLen) = cbor.Map(0);

        require(mapLen == 5 || mapLen == 4, "expected 4 or 5 fields in commit");

        for (uint8 mapIdx = 0; mapIdx < mapLen; mapIdx++) {
            bytes32 mapKey;
            (i, mapKey,) = cbor.String32(i, 7);
            if (bytes3(mapKey) == "did") {
                (i, commit.did) = cbor.String(i);
                // TODO: did formats? more comprehensive validation?
                require(bytes(commit.did).length == 32, "commit did string must be 32 bytes");
            } else if (bytes7(mapKey) == "version") {
                uint8 version;
                (i, version) = cbor.UInt8(i);
                require(version == COMMIT_VERSION, "commit version number must be 3");
            } else if (bytes4(mapKey) == "data") {
                (i, commit.data) = cbor.Cid(i);
            } else if (bytes4(mapKey) == "prev") {
                // TODO: possible assertions?
                (i,) = cbor.NullableCid(i);
            } else if (bytes3(mapKey) == "rev") {
                // monotonic commit timestamp
                (i, commit.rev) = cbor.String(i);
            } else {
                // TODO: ignore unknown keys?
                revert("unexpected commit field");
            }
        }

        cbor.requireComplete(i);
    }
}
