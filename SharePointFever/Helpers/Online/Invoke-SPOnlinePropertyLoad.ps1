<#
    .SYNOPSIS
        Facilitates the loading of specific properties of a ClientObject object
        in the Microsoft.SharePoint.Client namespace.

    .DESCRIPTION
        Because using C# lambada expressions in PowerShell is painful, this
        helper function will help using the load function of a ClientObject
        object in the Microsoft.SharePoint.Client namespace. For more
        information, refer to the StackOverflow link in the LINK section. For
        example the following query is converted to the function:
        ctx.Load(list, l => list.Title, l => list.Id)
        Invoke-SPOnlinePropertyLoad -InputObject $item -PropertyName @('Id')

    .LINK
        https://stackoverflow.com/questions/34336300/how-do-i-do-a-lambda-expression-in-powershell
#>
function Invoke-SPOnlinePropertyLoad
{
    [Cmdlet()]
    param
    (
        # The Microsoft.SharePoint.Client.ClientObject to populate.
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Microsoft.SharePoint.Client.ClientObject]
        $InputObject,

        # The object properties to populate.
        [Parameter(Mandatory = $true, Position = 1)]
        [System.String[]]
        $PropertyName
    )

    process
    {
        $type = $object.GetType()

        $exprType = [System.Linq.Expressions.Expression]
        $parameterExprType = [System.Linq.Expressions.ParameterExpression].MakeArrayType()
        $lambdaMethod = $exprType.GetMethods() | ? { $_.Name -eq "Lambda" -and $_.IsGenericMethod -and $_.GetParameters().Length -eq 2 -and $_.GetParameters()[1].ParameterType -eq $parameterExprType }
        $lambdaMethodGeneric = Invoke-Expression "`$lambdaMethod.MakeGenericMethod([System.Func``2[$($type.FullName),System.Object]])"
        $expressions = @()

        foreach ($propertyName in $propertyNames) {
            $param1 = [System.Linq.Expressions.Expression]::Parameter($type, "p")
            try {
                $name1 = [System.Linq.Expressions.Expression]::Property($param1, $propertyName)
            } catch {
                Write-Error "Instance property '$propertyName' is not defined for type $type"
                return
            }
            $body1 = [System.Linq.Expressions.Expression]::Convert($name1, [System.Object])
            $expression1 = $lambdaMethodGeneric.Invoke($null, [System.Object[]] @($body1, [System.Linq.Expressions.ParameterExpression[]] @($param1)))

            if ($collectionObject -ne $null) {
                $expression1 = [System.Linq.Expressions.Expression]::Quote($expression1)
            }
            $expressions += @($expression1)
        }

        $object.Context.Load($object, $expressions)
        if ($executeQuery) { $object.Context.ExecuteQuery() }
    }
}

    # [CmdletBinding(DefaultParameterSetName='ClientObject')]
    # param (
    #     # The Microsoft.SharePoint.Client.ClientObject to populate.
    #     [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, ParameterSetName = "ClientObject")]
    #     [Microsoft.SharePoint.Client.ClientObject]
    #     $object,

    #     # The Microsoft.SharePoint.Client.ClientObject that contains the collection object.
    #     [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, ParameterSetName = "ClientObjectCollection")]
    #     [Microsoft.SharePoint.Client.ClientObject]
    #     $parentObject,

    #     # The Microsoft.SharePoint.Client.ClientObjectCollection to populate.
    #     [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "ClientObjectCollection")]
    #     [Microsoft.SharePoint.Client.ClientObjectCollection]
    #     $collectionObject,

    #     # The object properties to populate
    #     [Parameter(Mandatory = $true, Position = 1, ParameterSetName = "ClientObject")]
    #     [Parameter(Mandatory = $true, Position = 2, ParameterSetName = "ClientObjectCollection")]
    #     [string[]]
    #     $propertyNames,

    #     # The parent object's property name corresponding to the collection object to retrieve (this is required to build the correct lamda expression).
    #     [Parameter(Mandatory = $true, Position = 3, ParameterSetName = "ClientObjectCollection")]
    #     [string]
    #     $parentPropertyName,

    #     # If specified, execute the ClientContext.ExecuteQuery() method.
    #     [Parameter(Mandatory = $false, Position = 4)]
    #     [switch]
    #     $executeQuery
    # )

    # process
    # {
    #     if ($PsCmdlet.ParameterSetName -eq "ClientObject") {
    #         $type = $object.GetType()
    #     } else {
    #         $type = $collectionObject.GetType()
    #         if ($collectionObject -is [Microsoft.SharePoint.Client.ClientObjectCollection]) {
    #             $type = $collectionObject.GetType().BaseType.GenericTypeArguments[0]
    #         }
    #     }

    #     $exprType = [System.Linq.Expressions.Expression]
    #     $parameterExprType = [System.Linq.Expressions.ParameterExpression].MakeArrayType()
    #     $lambdaMethod = $exprType.GetMethods() | ? { $_.Name -eq "Lambda" -and $_.IsGenericMethod -and $_.GetParameters().Length -eq 2 -and $_.GetParameters()[1].ParameterType -eq $parameterExprType }
    #     $lambdaMethodGeneric = Invoke-Expression "`$lambdaMethod.MakeGenericMethod([System.Func``2[$($type.FullName),System.Object]])"
    #     $expressions = @()

    #     foreach ($propertyName in $propertyNames) {
    #         $param1 = [System.Linq.Expressions.Expression]::Parameter($type, "p")
    #         try {
    #             $name1 = [System.Linq.Expressions.Expression]::Property($param1, $propertyName)
    #         } catch {
    #             Write-Error "Instance property '$propertyName' is not defined for type $type"
    #             return
    #         }
    #         $body1 = [System.Linq.Expressions.Expression]::Convert($name1, [System.Object])
    #         $expression1 = $lambdaMethodGeneric.Invoke($null, [System.Object[]] @($body1, [System.Linq.Expressions.ParameterExpression[]] @($param1)))

    #         if ($collectionObject -ne $null) {
    #             $expression1 = [System.Linq.Expressions.Expression]::Quote($expression1)
    #         }
    #         $expressions += @($expression1)
    #     }


    #     if ($PsCmdlet.ParameterSetName -eq "ClientObject") {
    #         $object.Context.Load($object, $expressions)
    #         if ($executeQuery) { $object.Context.ExecuteQuery() }
    #     } else {
    #         $newArrayInitParam1 = Invoke-Expression "[System.Linq.Expressions.Expression``1[System.Func````2[$($type.FullName),System.Object]]]"
    #         $newArrayInit = [System.Linq.Expressions.Expression]::NewArrayInit($newArrayInitParam1, $expressions)

    #         $collectionParam = [System.Linq.Expressions.Expression]::Parameter($parentObject.GetType(), "cp")
    #         $collectionProperty = [System.Linq.Expressions.Expression]::Property($collectionParam, $parentPropertyName)

    #         $expressionArray = @($collectionProperty, $newArrayInit)
    #         $includeMethod = [Microsoft.SharePoint.Client.ClientObjectQueryableExtension].GetMethod("Include")
    #         $includeMethodGeneric = Invoke-Expression "`$includeMethod.MakeGenericMethod([$($type.FullName)])"

    #         $lambdaMethodGeneric2 = Invoke-Expression "`$lambdaMethod.MakeGenericMethod([System.Func``2[$($parentObject.GetType().FullName),System.Object]])"
    #         $callMethod = [System.Linq.Expressions.Expression]::Call($null, $includeMethodGeneric, $expressionArray)

    #         $expression2 = $lambdaMethodGeneric2.Invoke($null, @($callMethod, [System.Linq.Expressions.ParameterExpression[]] @($collectionParam)))

    #         $parentObject.Context.Load($parentObject, $expression2)
    #         if ($executeQuery) { $parentObject.Context.ExecuteQuery() }
    #     }
    # }
    # end { }
    # }