DefinitionBlock ("", "SSDT", 2, "hack", "macOS", 0x00000000)
{
    External (_PR_.CPU0, ProcessorObj)
    External (_SB_.PCI0.EH01, DeviceObj)
    External (_SB_.PCI0.EH02, DeviceObj)
    External (_SB_.PCI0.LPCB, DeviceObj)
    External (_SB_.PCI0.LPCB.HPET, DeviceObj)
    
// CPU    
    Method (PMPM, 4, NotSerialized)
    {
        If ((Arg2 == Zero))
        {
            Return (Buffer (One)
            {
                 0x03                                             
            })
        }

        Return (Package (0x02)
        {
            "plugin-type", 
            One
        })
    }

    Scope (\_PR.CPU0)
    {
        Method (_DSM, 4, NotSerialized)  
        {
            Return (PMPM (Arg0, Arg1, Arg2, Arg3))
        }
    }
    
// HPET    
    Name (\_SB.PCI0.LPCB.HPET._CRS, ResourceTemplate ()  
    {
        IRQNoFlags ()
            {0,8,11}
        Memory32Fixed (ReadWrite,
            0xFED00000,         
            0x00000400,        
            )
    })
// Disable EHC1&EHC2
    Scope (_SB.PCI0.EH01)
    {
        OperationRegion (RMP1, PCI_Config, 0x54, 0x02)
        Field (RMP1, WordAcc, NoLock, Preserve)
        {
            PSTE,   2
        }

        Method (_INI, 0, NotSerialized)  
        {
            PSTE = 0x03
            ^^LPCB.FDE1 = One
        }
    }

    Scope (_SB.PCI0.EH02)
    {
        OperationRegion (RMP1, PCI_Config, 0x54, 0x02)
        Field (RMP1, WordAcc, NoLock, Preserve)
        {
            PSTE,   2
        }

        Method (_INI, 0, NotSerialized)  
        {
            PSTE = 0x03
            ^^LPCB.FDE2 = One
        }
    }
// EC
    Scope (_SB.PCI0.LPCB)
    {
        Device (EC)
        {
            Name (_HID, "ACID0001")  
            Method (_STA, 0, NotSerialized)  
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }
        }

// Disable EHC1&EHC2                
        OperationRegion (RMP1, PCI_Config, 0xF0, 0x04)
        Field (RMP1, DWordAcc, NoLock, Preserve)
        {
            RCB1,   32
        }

        OperationRegion (FDM1, SystemMemory, ((RCB1 & 0xFFFFFFFFFFFFC000) + 0x3418), 0x04)
        Field (FDM1, DWordAcc, NoLock, Preserve)
        {
                ,   13, 
            FDE2,   1, 
                ,   1, 
            FDE1,   1
        }
    }
}

