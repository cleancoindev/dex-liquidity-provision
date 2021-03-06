pragma solidity >= 0.5.0 < 0.7.0;

import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";

contract FleetFactoryDeterministic {
  GnosisSafeProxyFactory public proxyFactory;

  event FleetDeployed(address indexed owner, address[] fleet);

  constructor(GnosisSafeProxyFactory _proxyFactory) public {
    proxyFactory = _proxyFactory;
  }

  function deployFleetWithNonce(address owner, uint256 size, address template, uint256 saltNonce) external {
    GnosisSafeProxyFactory _proxyFactory = proxyFactory;
    address[] memory fleet = new address[](size);
    address[] memory ownerList = new address[](1);
    ownerList[0] = owner;
    for (uint i = 0; i < size; i++) {
      address payable proxy = address(
        _proxyFactory.createProxyWithNonce(
          template,
          "",
          uint256(
            keccak256(
              abi.encodePacked(saltNonce, i)
            )
          )
        )
      );
      fleet[i] = proxy;
      require(fleet[i] != address(0), "fleet deployment failed");
      GnosisSafe safe = GnosisSafe(proxy);
      // safe is set up to have a single owner
      safe.setup(
        ownerList,
        1,
        address(0),
        "",
        address(0),
        address(0),
        0,
        address(0)
      );
    }
    emit FleetDeployed(owner, fleet);
  }
}
