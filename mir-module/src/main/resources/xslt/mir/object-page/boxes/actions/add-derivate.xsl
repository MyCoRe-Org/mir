<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mcrpi="http://www.mycore.de/xslt/pi"
  xmlns:mcrproperty="http://www.mycore.de/xslt/property"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="action[@name='add-derivate']" mode="object-action">
    <xsl:param name="object-id" as="xs:string" tunnel="yes" />
    <xsl:param name="write" as="xs:boolean" tunnel="yes" />

    <xsl:variable name="allowed-to-edit-pi" select="
      some $role in tokenize(string(mcrproperty:get('MIR.Strategy.EditPIRoles')), ',') ! normalize-space() satisfies mcracl:is-current-user-in-role($role)
    " />
    <xsl:if test="$write and mcracl:check-permission('', 'create-derivate')
      and (not(mcrpi:has-managed-pi($object-id)) or $allowed-to-edit-pi)">
      <li class="mir-action-item mir-action-item-add-derivate">
        <a onclick="javascript: $('.drop-to-object-optional').toggle();" class="dropdown-item">
          <xsl:value-of select="mcri18n:translate('mir.upload.addDerivate')" />
        </a>
      </li>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
