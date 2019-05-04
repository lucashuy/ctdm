function GM:ShowHelp(ply)
    net.Start("CTDM.openGunMenu")
    net.Send(ply)
end