<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:miraccesskeyutil="http://www.mycore.de/xslt/miraccesskeyutil"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template name="print-manage-access-keys-menu-item">
    <xsl:param name="reference" as="xs:string" />

    <xsl:variable name="available-permissions" select="
      miraccesskeyutil:get-manageable-permissions($reference, ('read', 'writedb'))
    " />
    <xsl:if test="exists($available-permissions)">
      <li class="mir-action-item mir-action-item-manage-access-key">
        <xsl:variable name="permissions" select="string-join($available-permissions, ',')" />
        <a
          role="menuitem"
          tabindex="-1"
          class="dropdown-item"
          href="{$WebApplicationBaseURL}access-key-manager/{$reference}?availablePermissions={$permissions}"
        >
          <xsl:value-of select="mcri18n:translate('mir.accesskey.manage')" />
        </a>
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template name="print-set-access-key-menu-item">
    <xsl:param name="reference" as="xs:string" />

    <li class="mir-action-item mir-action-item-activate-access-key">
      <a
        role="menuitem"
        tabindex="-1"
        href="{$WebApplicationBaseURL}accesskey/set.xed?objId={$reference}&amp;url={encode-for-uri(string($RequestURL))}"
        class="dropdown-item">
        <xsl:value-of select="mcri18n:translate('mir.accesskey.setOnUser')" />
      </a>
    </li>
  </xsl:template>

</xsl:stylesheet>
