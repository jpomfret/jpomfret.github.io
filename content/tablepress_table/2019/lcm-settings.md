---
title: "LCM Settings"
date: "2019-03-24"
---

\[\["Setting","Definition"\],\["ActionAfterReboot","What should happen after a reboot. ContinueConfiguration or StopConfiguration."\],\["CertificateID","Thumbprint of the certificate used to encrypt the MOF file. If this isn\\u2019t used passwords are stored in plain text in the MOF."\],\["ConfigurationMode","What the LCM does with the configuration document. This setting can be used to automatically keep your node in the desired state. ApplyOnly, ApplyAndMonitor or ApplyAndAutoCorrect."\],\["ConfigurationModeFrequencyMins","How often should the LCM check configurations and apply them. If the ConfigurationMode is ApplyOnly this is ignored."\],\["RebootNodeIfNeeded","If during the configuration a reboot is required should the node automatically reboot."\],\["RefreshMode","Does the LCM passively wait for configurations to be pushed to it (push), or actively check in with the pull server for new configurations (pull)."\]\]
