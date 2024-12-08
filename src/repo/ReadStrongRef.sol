// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import "solidity-cbor/ReadCbor.sol";
import "solidity-cbor/tags/ReadCidSha256.sol";

using ReadCbor for bytes;

library ReadStrongRef {
    bytes26 private constant nsid = "com.atproto.repo.strongRef";

    function readStrongRef(bytes memory cborData, uint32 byteIdx) internal pure returns (uint32, string memory) {
        uint32 mapLen;
        (byteIdx, mapLen) = cborData.Map(byteIdx);

        require(mapLen >= 2, "expected 2 required fields in `com.atproto.repo.strongRef`");

        bytes32 mapKey;

        string memory cid;
        string memory uri;

        for (uint mapIdx = 0; mapIdx < mapLen; mapIdx++) {
            (byteIdx, mapKey,) = cborData.String32(byteIdx, 3);
            if (mapKey == "cid") {
                (byteIdx, cid) = cborData.String(byteIdx);
            } else if (mapKey == "uri") {
                (byteIdx, uri) = cborData.String(byteIdx);
            } else {
                revert("unexpected record key");
            }
        }

        return (byteIdx, string(abi.encodePacked(uri, "#", cid)));
    }
}
