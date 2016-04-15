/**
 * $Id$ $Revision$
 * $Date$
 * 
 * @author Ren\u00E9 Adler (eagle)
 * 
 * This file is part of *** M y C o R e *** See http://www.mycore.de/ for
 * details.
 * 
 * This program is free software; you can use it, redistribute it and / or
 * modify it under the terms of the GNU General Public License (GPL) as
 * published by the Free Software Foundation; either version 2 of the License or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 * 
 * You should have received a copy of the GNU General Public License along with
 * this program, in a file called gpl.txt or license.txt. If not, write to the
 * Free Software Foundation Inc., 59 Temple Place - Suite 330, Boston, MA
 * 02111-1307 USA
 */
var PasswordGenerator = {};
PasswordGenerator.genPassword = function(plength) {
	var keylistalpha = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
	var keylistint = "123456789";
	var keylistspec = "!@#_%$";
	var temp = '';
	var len = plength / 2;
	var len = len - 1;
	var lenspec = plength - len - len;

	for (i = 0; i < len; i++)
		temp += keylistalpha.charAt(Math.floor(Math.random() * keylistalpha.length));

	for (i = 0; i < lenspec; i++)
		temp += keylistspec.charAt(Math.floor(Math.random() * keylistspec.length));

	for (i = 0; i < len; i++)
		temp += keylistint.charAt(Math.floor(Math.random() * keylistint.length));

	temp = temp.split('').sort(function() {
		return 0.5 - Math.random()
	}).join('');

	return temp;
}

jQuery(document).ready(function() {
	jQuery("#readKeyGenerator").click(function() {
		jQuery("#readKey").val(PasswordGenerator.genPassword(8));
	});
	jQuery("#writeKeyGenerator").click(function() {
		jQuery("#writeKey").val(PasswordGenerator.genPassword(8));
	});
});