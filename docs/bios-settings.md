# BIOS Settings Guide for Dell OptiPlex Micros

## Table of Contents
1. [General](#General)
2. [System Configuration](#System-Configuration)
3. [Video](#Video)
4. [Security](#Security)
5. [Secure Boot](#Secure-Boot)
6. [Intel&reg; Software Guard Extensions&trade;](#Intel-Software-Guard-Extensions)
7. [Performance](#Performance)
8. [Power Management](#Power-Management)
9. [POST Behavior](#POST-Behavior)
10. [Virtualization Support](#Virtualization-Support)
11. [Wireless](#Wireless)
12. [Maintenance](#Maintenance)
13. [Advanced configurations](#Advanced-configurations)
14. [SupportAssist System Resolution](#SupportAssist-System-Resolution)


## General
| Option                  | Setting                                                                            |
|-------------------------|------------------------------------------------------------------------------------|
| Boot sequence           | UEFI: Boot from NVMe SSD first, followed by USB devices. Disable Onboard NIC(IPV6) |
| Advanced Boot Options   | Enable Legacy Option ROMs, Disable Attempt Legacy Boot                             |
| UEFI Boot Path Security | Always, Except Internal HDD                                                        |

## System Configuration
| Option                  | Setting                                  |
|-------------------------|------------------------------------------|
| Integrated NIC          | Enable UEFI Network Stack: Enabled w/PXE |
| SATA Operation          | AHCI                                     |
| Drives                  | All Enabled                              |
| SMART Reporting         | Disabled                                 |
| USB Configuration       | All Enabled                              |
| Front USB Configuration | All Enabled                              |
| Rear USB Configuration  | All Enabled                              |
| Audio                   | All Enabled                              |
| Dust Filter Maintenance | Disabled                                 |
| Enable Watchdog Timer   | Enabled                                  |

## Video
| Option          | Setting |
|-----------------|---------|
| Primary Display | Auto    |

## Security
| Option                        | Setting                                                                                                             |
|-------------------------------|---------------------------------------------------------------------------------------------------------------------|
| Admin Password                | Not Set                                                                                                             |
| System Password               | Not Set                                                                                                             |
| Internal HDD-0 Password       | Not Set                                                                                                             |
| Strong Password               | Disabled                                                                                                            |
| Password Configuration        | 4-32 for both Admin and System Password                                                                             |
| Password Bypass               | Disabled                                                                                                            |
| Password Change               | Enabled                                                                                                             |
| UEFI Capsule Firmware Updates | Enabled                                                                                                             |
| TPM 2.0 Security              | TPM On, Attestation Enabled, Key Storage Enabled, SHA-256 Enabled, TPM 2.0 Security Enabled, Other Options Disabled |
| Absolute&reg;                 | Disabled                                                                                                            |
| Chassis Intrustion            | Disabled                                                                                                            |
| Admin Setup Lockout           | Disabled                                                                                                            |
| Master Password Lockout       | Disabled                                                                                                            |
| SMM Security Mitigation       | Enabled                                                                                                             |

## Secure Boot
| Option                | Setting             |
|-----------------------|---------------------|
| Secure Boot Enable    | Disabled            |
| Secure Boot Mode      | Deployed Mode       |
| Expert Key Management | Disable Custom Mode |

## Intel&reg; Software Guard Extensions&trade;

| Option                       | Setting             |
|------------------------------|---------------------|
| Intel&reg; SGX&trade; Enable | Software Controlled |

## Performance
| Option                | Setting             |
|-----------------------|---------------------|
| Multi Core Support    | All            |
| Intel&reg; SpeedStep&trade;    | Enabled            |
| C-States Control    | Enabled            |
| Intel&reg; TurboBoost&trade;   | Enabled            |

## Power Management
| Option                              | Setting  |
|-------------------------------------|----------|
| AC Recovery                         | Power On |
| Enable Intel Speed Shift Technology | Enabled  |
| Auto On Time                        | Disabled |
| Deep Sleep Control                  | Disabled |
| USB Wake Support                    | Enabled  |
| Wake on LAN/WLAN                    | LAN Only |
| Block Sleep                         | Enabled  |

## POST Behavior
| Option                | Setting                         |
|-----------------------|---------------------------------|
| Adapter Warnings      | Disabled                        |
| Numlock LED           | Enabled                         |
| Keyboard Errors       | Disabled                        |
| Fastboot              | Minimal                         |
| Extend BIOS POST Time | 0 seconds                       |
| Full Screen Logo      | Disabled                        |
| Warnings and Errors   | Continue on Warnings and Errors |

## Virtualization Support
| Option            | Setting |
|-------------------|---------|
| Virtualization    | Enabled |
| VT for Direct I/O | Enabled |

## Wireless
| Option                 | Setting    |
|------------------------|------------|
| Wireless Device Enable | All Enabled |

## Maintenance
| Option         | Setting                                                            |
|----------------|--------------------------------------------------------------------|
| SERR Messages  | Enabled                                                            |
| BIOS Downgrade | Enabled                                                            |
| BIOS Recovery  | BIOS Recovery from Hard Drive enabled, BIOS Auto-recovery Disabled |

## Advanced configurations
| Option | Setting |
|--------|---------|
| ASPM   | Auto    |

## SupportAssist System Resolution
| Option                     | Setting |
|----------------------------|---------|
| Auto OS Recovery Threshold | OFF     |
| SupportAssist OS Recovery  | Enabled |
| BIOSConnect                | Enabled |
