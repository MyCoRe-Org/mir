<?xml version="1.0" encoding="UTF-8"?>

<!-- XSL to display data of a login user -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xalan="http://xml.apache.org/xalan" xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:const="xalan://org.mycore.user2.MCRUser2Constants"
  exclude-result-prefixes="xsl xalan i18n acl const mcrxsl"
>

  <xsl:include href="MyCoReLayout.xsl" />
  <xsl:include href="user-orcid.xsl" />

  <xsl:variable name="PageID" select="'show-user'" />

  <xsl:variable name="PageTitle">
    <xsl:call-template name="user-display-name"/>
  </xsl:variable>

  <xsl:param name="step" />
  <xsl:param name="MCR.ORCID2.OAuth.ClientSecret"/>
  <xsl:param name="MCR.ORCID2.OAuth.Scope"/>
  <xsl:param name="MCR.ORCID2.BaseURL"/>
  <xsl:param name="MIR.ORCID.InfoURL"/>
  <xsl:param name="orcidIntegrationEnabled" select="string-length($MCR.ORCID2.OAuth.ClientSecret) &gt; 0"/>

  <xsl:param name="MIR.User.ShowSimpleDetailsOnly" select="'false'" />

  <xsl:variable name="uid">
    <xsl:value-of select="/user/@name" />
    <xsl:if test="not ( /user/@realm = 'local' )">
      <xsl:text>@</xsl:text>
      <xsl:value-of select="/user/@realm" />
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="owns" select="document(concat('user:getOwnedUsers:',$uid))/owns" />

  <xsl:template match="user" mode="actions">
    <xsl:variable name="isCurrentUser" select="$CurrentUser = $uid" />
    <xsl:if test="(string-length($step) = 0) or ($step = 'changedPassword')">
      <xsl:variable name="isUserAdmin" select="acl:checkPermission(const:getUserAdminPermission())" />
      <xsl:choose>
        <xsl:when test="$isUserAdmin">
          <a class="btn btn-secondary" href="{$WebApplicationBaseURL}authorization/change-user.xed?action=save&amp;id={$uid}">
            <xsl:value-of select="i18n:translate('component.user2.admin.changedata')" />
          </a>
        </xsl:when>
        <xsl:when test="not($isCurrentUser)">
          <a class="btn btn-secondary" href="{$WebApplicationBaseURL}authorization/change-read-user.xed?action=save&amp;id={$uid}">
            <xsl:value-of select="i18n:translate('component.user2.admin.changedata')" />
          </a>
        </xsl:when>
        <xsl:when test="$isCurrentUser and not(/user/@locked = 'true')">
          <a class="btn btn-secondary" href="{$WebApplicationBaseURL}authorization/change-current-user.xed?action=saveCurrentUser">
            <xsl:value-of select="i18n:translate('component.user2.admin.changedata')" />
          </a>
        </xsl:when>
      </xsl:choose>
      <xsl:if test="/user/@realm = 'local' and (not($isCurrentUser) or not(/user/@locked = 'true'))">
        <xsl:choose>
          <xsl:when test="$isCurrentUser">
            <a class="btn btn-secondary" href="{$WebApplicationBaseURL}authorization/change-password.xed?action=password">
              <xsl:value-of select="i18n:translate('component.user2.admin.changepw')" />
            </a>
          </xsl:when>
          <xsl:otherwise>
            <a class="btn btn-secondary" href="{$WebApplicationBaseURL}authorization/change-password.xed?action=password&amp;id={$uid}">
              <xsl:value-of select="i18n:translate('component.user2.admin.changepw')" />
            </a>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:if test="$isUserAdmin and not($isCurrentUser)">
        <a class="btn btn-danger" href="{$ServletsBaseURL}MCRUserServlet?action=show&amp;id={$uid}&amp;XSL.step=confirmDelete">
          <xsl:value-of select="i18n:translate('component.user2.admin.userDeleteYes')" />
        </a>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="user">
    <xsl:variable name="isUserAdmin" select="acl:checkPermission(const:getUserAdminPermission())" />
    <xsl:variable name="fullDetails" select="$isUserAdmin or not($MIR.User.ShowSimpleDetailsOnly='true')" />
    <div class="user-details">
      <div id="buttons" class="btn-group float-end">
        <xsl:apply-templates select="." mode="actions" />
      </div>
      <div class="clearfix" />
      <h2>
        <xsl:call-template name="user-display-name"/>
      </h2>
      <xsl:if test="$step = 'confirmDelete'">
        <div class="section alert alert-danger">
          <p>
            <strong>
              <xsl:value-of select="i18n:translate('component.user2.admin.userDeleteRequest')" />
            </strong>
            <br />
            <xsl:value-of select="i18n:translate('component.user2.admin.userDeleteExplain')" />
            <br />
            <xsl:if test="$owns/user">
              <strong>
                <xsl:value-of select="i18n:translate('component.user2.admin.userDeleteExplainRead1')" />
                <xsl:value-of select="count($owns/user)" />
                <xsl:value-of select="i18n:translate('component.user2.admin.userDeleteExplainRead2')" />
              </strong>
            </xsl:if>
          </p>
          <form class="float-start" method="post" action="MCRUserServlet">
            <input name="action" value="delete" type="hidden" />
            <input name="id" value="{$uid}" type="hidden" />
            <input name="XSL.step" value="deleted" type="hidden" />
            <input value="{i18n:translate('component.user2.button.deleteYes')}" class="btn btn-danger" type="submit" />
          </form>
          <form method="get" action="MCRUserServlet">
            <input name="action" value="show" type="hidden" />
            <input name="id" value="{$uid}" type="hidden" />
            <input value="{i18n:translate('component.user2.button.cancelNo')}" class="btn btn-secondary" type="submit" />
          </form>
        </div>
      </xsl:if>
      <xsl:if test="$step = 'deleted'">
        <div class="section alert alert-success alert-dismissable">
          <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close" />
          <p>
            <strong>
              <xsl:value-of select="i18n:translate('component.user2.admin.userDeleteConfirm')" />
            </strong>
          </p>
        </div>
      </xsl:if>
      <xsl:if test="$step = 'changedPassword'">
        <div class="section alert alert-success alert-dismissable">
          <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close" />
          <p>
            <strong>
              <xsl:value-of select="i18n:translate('component.user2.admin.passwordChangeConfirm')" />
            </strong>
          </p>
        </div>
      </xsl:if>
      <div class="section" id="sectionlast">
        <div class="table-responsive">
          <table class="user table">
            <tr class="d-flex">
              <th class="col-md-3">
                <xsl:value-of select="i18n:translate('component.user2.admin.userAccount')" />
              </th>
              <td class="col-md-9">
                <xsl:apply-templates select="." mode="name" />
              </td>
            </tr>
            <xsl:if test="$fullDetails or string-length(password/@hint) &gt; 0">
              <tr class="d-flex">
                <th class="col-md-3">
                  <xsl:value-of select="i18n:translate('component.user2.admin.passwordHint')" />
                </th>
                <td class="col-md-9">
                  <xsl:value-of select="password/@hint" />
                </td>
              </tr>
            </xsl:if>
            <tr class="d-flex">
              <th class="col-md-3">
                <xsl:value-of select="i18n:translate('component.user2.admin.user.lastLogin')" />
              </th>
              <td class="col-md-9">
                <xsl:call-template name="formatISODate">
                  <xsl:with-param name="date" select="lastLogin" />
                  <xsl:with-param name="format" select="i18n:translate('component.user2.metaData.dateTime')" />
                </xsl:call-template>
              </td>
            </tr>
            <xsl:if test="$fullDetails or string-length(validUntil) &gt; 0">
              <tr class="d-flex">
                <th class="col-md-3">
                  <xsl:value-of select="i18n:translate('component.user2.admin.user.validUntil')" />
                </th>
                <td class="col-md-9">
                  <xsl:call-template name="formatISODate">
                    <xsl:with-param name="date" select="validUntil" />
                    <xsl:with-param name="format" select="i18n:translate('component.user2.metaData.dateTime')" />
                  </xsl:call-template>
                </td>
              </tr>
            </xsl:if>
            <tr class="d-flex">
              <th class="col-md-3">
                <xsl:value-of select="i18n:translate('component.user2.admin.user.name')" />
              </th>
              <td class="col-md-9">
                <xsl:value-of select="realName" />
              </td>
            </tr>
            <xsl:if test="eMail">
              <tr class="d-flex">
                <th class="col-md-3">
                  <xsl:value-of select="i18n:translate('component.user2.admin.user.email')" />
                </th>
                <td class="col-md-9">
                  <a href="mailto:{eMail}">
                    <xsl:value-of select="eMail" />
                  </a>
                </td>
              </tr>
            </xsl:if>
            <xsl:if test="$fullDetails">
              <tr class="d-flex">
                <th class="col-md-3">
                  <xsl:value-of select="i18n:translate('component.user2.admin.user.locked')" />
                </th>
                <td class="col-md-9">
                  <xsl:choose>
                    <xsl:when test="@locked='true'">
                      <xsl:value-of select="i18n:translate('component.user2.admin.user.locked.true')" />
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="i18n:translate('component.user2.admin.user.locked.false')" />
                    </xsl:otherwise>
                  </xsl:choose>
                </td>
              </tr>
            </xsl:if>
            <xsl:if test="$fullDetails">
              <tr class="d-flex">
                <th class="col-md-3">
                  <xsl:value-of select="concat(i18n:translate('component.user2.admin.user.disabled'), ':')" />
                </th>
                <td class="col-md-9">
                  <xsl:choose>
                    <xsl:when test="@disabled='true'">
                      <xsl:value-of select="i18n:translate('component.user2.admin.user.disabled.true')" />
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="i18n:translate('component.user2.admin.user.disabled.false')" />
                    </xsl:otherwise>
                  </xsl:choose>
                </td>
              </tr>
              <tr class="d-flex">
                <th class="col-md-3">
                  <xsl:value-of select="i18n:translate('component.user2.admin.user.attributes')" />
                </th>
                <td class="col-md-9">
                  <dl>
                    <!-- filter orcid attributes -->
                    <xsl:for-each select="attributes/attribute[not(@name='id_orcid' or starts-with(@name, 'orcid_credential_') or  starts-with(@name, 'orcid_user_properties_'))]">
                      <dt>
                        <xsl:value-of select="@name" />
                      </dt>
                      <dd>
                        <xsl:value-of select="@value" />
                      </dd>
                    </xsl:for-each>
                  </dl>
                </td>
              </tr>
            </xsl:if>
            <xsl:if test="attributes/attribute[@name='id_orcid']" >
              <tr class="d-flex">
                <th class="col-md-3">
                  <xsl:value-of select="i18n:translate('user.profile.id.orcid')" />
                  <xsl:text>:</xsl:text>
                </th>
                <td class="col-md-9">
                  <xsl:variable name="url" select="concat($MCR.ORCID2.BaseURL, '/', attributes/attribute[@name='id_orcid']/@value)" />
                  <a href="{$url}">
                    <img alt="ORCID iD" src="{$WebApplicationBaseURL}images/orcid_icon.svg" class="orcid-icon" />
                    <xsl:value-of select="$url" />
                  </a>
                </td>
              </tr>
            </xsl:if>
            <xsl:if test="$fullDetails">
              <tr class="d-flex">
                <th class="col-md-3">
                  <xsl:value-of select="i18n:translate('component.user2.admin.owner')" />
                </th>
                <td class="col-md-9">
                  <xsl:apply-templates select="owner" mode="link" />
                  <xsl:if test="count(owner)=0">
                    <xsl:value-of select="i18n:translate('component.user2.admin.userIndependent')" />
                  </xsl:if>
                </td>
              </tr>
            </xsl:if>
            <xsl:if test="$fullDetails">
              <tr class="d-flex">
                <th class="col-md-3">
                  <xsl:value-of select="i18n:translate('component.user2.admin.roles')" />
                </th>
                <td class="col-md-9">
                  <xsl:for-each select="roles/role">
                    <xsl:value-of select="@name" />
                    <xsl:variable name="lang">
                      <xsl:call-template name="selectPresentLang">
                        <xsl:with-param name="nodes" select="label" />
                      </xsl:call-template>
                    </xsl:variable>
                    <xsl:value-of select="concat(' [',label[lang($lang)]/@text,']')" />
                    <xsl:if test="position() != last()">
                      <br />
                    </xsl:if>
                  </xsl:for-each>
                </td>
              </tr>
            </xsl:if>
            <xsl:if test="$fullDetails">
              <tr class="d-flex">
                <th class="col-md-3">
                  <xsl:value-of select="i18n:translate('component.user2.admin.userOwns')" />
                </th>
                <td class="col-md-9">
                  <xsl:for-each select="$owns/user">
                    <xsl:apply-templates select="." mode="link" />
                    <xsl:if test="position() != last()">
                      <br />
                    </xsl:if>
                  </xsl:for-each>
                </td>
              </tr>
            </xsl:if>
          </table>
        </div>
        <xsl:if test="$orcidIntegrationEnabled">
          <xsl:call-template name="orcid" />
        </xsl:if>
      </div>
    </div>
    <script type="module" src="{$WebApplicationBaseURL}js/mir/user.js"/>
  </xsl:template>

  <xsl:template match="user|owner" mode="link">
    <xsl:variable name="uid">
      <xsl:value-of select="@name" />
      <xsl:if test="not ( @realm = 'local' )">
        <xsl:text>@</xsl:text>
        <xsl:value-of select="@realm" />
      </xsl:if>
    </xsl:variable>
    <a href="MCRUserServlet?action=show&amp;id={$uid}">
      <xsl:apply-templates select="." mode="name" />
    </a>
  </xsl:template>

  <xsl:template match="user|owner" mode="name">
    <xsl:value-of select="@name" />
    <xsl:text> [</xsl:text>
    <xsl:value-of select="@realm" />
    <xsl:text>]</xsl:text>
  </xsl:template>

  <xsl:template name="orcid">
    <article>
      <xsl:choose>
        <xsl:when test="attributes/attribute[starts-with(@name, 'orcid_credential_')]">
          <xsl:variable name="orcidCredentialAttributes"
            select="attributes/attribute[starts-with(@name, 'orcid_credential_')]"/>
          <h3>
            <span class="fas fa-check pr-1" aria-hidden="true"/>
            <xsl:value-of select="document('i18n:orcid.integration.confirmed.headline')"/>
          </h3>
          <p><xsl:value-of select="document('i18n:orcid.integration.confirmed.text')"/></p>
          <xsl:choose>
            <xsl:when test="@realm='orcid.org'">
              <xsl:variable name="orcid" select="substring-after($orcidCredentialAttributes[1]/@name, 'orcid_credential_')" />
              <xsl:call-template name="printOrcidSettingsButtonIfRequired">
                <xsl:with-param name="orcid" select="$orcid"/>
              </xsl:call-template>
              <br/><br/>
              <xsl:call-template name="printOrcidSettingsModal" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="document('i18n:orcid.integration.confirmedOrcids.text')"/>
              <ul>
                <xsl:for-each select="$orcidCredentialAttributes/@name">
                  <xsl:variable name="orcid" select="substring-after(., 'orcid_credential_')" />
                  <li>
                    <span class="mr-2"><xsl:value-of select="$orcid"/></span>
                    <xsl:call-template name="printOrcidSettingsButtonIfRequired">
                      <xsl:with-param name="orcid" select="$orcid"/>
                    </xsl:call-template>
                    <xsl:call-template name="printRevokeOrcidButton">
                      <xsl:with-param name="orcid" select="$orcid"/>
                    </xsl:call-template>
                  </li>
                </xsl:for-each>
              </ul>
              <xsl:call-template name="printOrcidSettingsModal" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <h3>
            <span class="far fa-hand-point-right pr-1" aria-hidden="true"/>
            <xsl:value-of select="document('i18n:orcid.integration.pending.headline')"/>
          </h3>
          <p><xsl:value-of select="document('i18n:orcid.integration.pending.intro')"/></p>
          <xsl:call-template name="printOrcidOAuthScopeDescriptionList">
            <xsl:with-param name="scopeString" select="$MCR.ORCID2.OAuth.Scope"/>
          </xsl:call-template>
          <xsl:call-template name="printShowOrcidOAuthButton">
            <xsl:with-param name="scope" select="$MCR.ORCID2.OAuth.Scope"/>
          </xsl:call-template>
          <br/><br/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="string-length($MIR.ORCID.InfoURL) &gt; 0">
        <a href="{$MIR.ORCID.InfoURL}">
          <xsl:value-of select="document('i18n:orcid.integration.more')"/>
        </a>
      </xsl:if>
    </article>
  </xsl:template>

  <xsl:template name="user-display-name">
    <xsl:choose>
      <xsl:when test="/user/realName">
        <xsl:value-of select="concat(i18n:translate('component.user2.admin.userDisplay'), ' ', /user/realName)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat(i18n:translate('component.user2.admin.userDisplay'), ' ', /user/@name)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
